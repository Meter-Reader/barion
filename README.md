# Barion

![Barion](https://github.com/Meter-reader/Barion/workflows/Ruby/badge.svg)
[![codecov](https://codecov.io/gh/Meter-Reader/barion/branch/main/graph/badge.svg?token=DCOKCM7B2J)](https://codecov.io/gh/Meter-Reader/barion)
[![Gem Version](https://badge.fury.io/rb/barion.svg)](https://badge.fury.io/rb/barion)

This is a Ruby-on-Rails engine to use the Barion Payment Gateway in any RoR application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'barion'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install barion
```

## Usage

### Initalization

After installing the gem you have to initalize it.
Just create a file in `config/initializers/barion.rb` with the below content:

```ruby
Barion.poskey = ''
Barion.publickey = ''
Barion.pixel_id = ''
Barion.sandbox = true
Barion.acronym = ''
Barion.default_payee = ''
```

#### POSKey and PublicKey (default: empty)

You can find your `POSKey` and `PublicKey` at the  Barion Shop website:

Test : <https://secure.test.barion.com/Shop/>

Production : <https://secure.barion.com/Shop/>

![POSKey and PublicKey at Barion Shop](https://docs.barion.com/images/2/2b/Poskey.jpg "POSKey and PublicKey at Barion Shop")

You have to open the shop Details from the `Action` dropdown of your shop. Please be aware that these values are different for Test and Production shops.

#### Pixel ID (default: '')

[Implementing the Base Barion Pixel](https://docs.barion.com/Implementing_the_Base_Barion_Pixel)

Your Barion Pixel ID can be found in the Details page of your Barion shop. Every webshop (with a unique POSKey) has a different Barion Pixel ID. You can find your Barion Pixel ID in your Barion wallet: click `Manage my shops` menu, `Actions` next to your shop and then `Details`.



#### Sandbox (default: true)

It is **highly recommended** to use a Test shop first to tune the code first. That's why `sandbox` is set to **true** by default.

#### Acronym (default: empty)

Acronym is used to generate the `payment_request_id` Barion requires to identify every payment request as the below code snippets shows. You can change this by overriding/decorating this method in your code.

```ruby
def create_payment_request_id
  self.payment_request_id = "#{::Barion.acronym}#{::Time.now.to_f.to_s.gsub('.', '')}" if payment_request_id.nil?
end
```

#### Default payee (Default: empty)

Barion requires an e-mail address in every transaction to identify the recipient user of the transaction. The Barion wallet which has this e-mail address registeres will receives the money when the payment is completed by the payer.

You can see this address in the Barion Shop interface below your shop icon on the top left corner.

### Set up your database

This gem comes with predefined models. To use them, you have to copy the migrations into your application and migrate them using:

```bash
bundle exec rails barion:install:migrations
bundle exec rails db:migrate SCOPE=barion
```

### Mounting the engine

You have to mount the Barion engine to be able to receive callback(s) from Barion Gateway like:

```ruby
mount ::Barion::Engine, at: "/barion"
```

### Creating payment

Once initialized you can create payments like below:

```ruby
payment = ::Barion:Payment.new
transaction = payment.transactions.build
item = transaction.items.build
```

* You can find the properties of Payment here: <https://docs.barion.com/Payment-Start-v2>,

* for the properties of Transaction see here: <https://docs.barion.com/PaymentTransaction>
(*Note*: Transaction is used not just for starting the payment but to collect transaction details during the payment lifecycle.)

* and for Item properties: <https://docs.barion.com/Item>

To check if all required properties are filled out you can use Rails built in validation:

```ruby
unless payment.valid?
payment.errors.object.each { |error|
  puts error.full_message
}
```

Once the payment is prepared you can start it by issuing

```ruby
payment.execute
```

This will send the required API requests to the Barion Gateway, depending on the `::Barion.sandbox` value either to the Test or the Production environment.

When the payment started you will receive callback(s) from Barion Gateway when the state of your payment has been changed. There are several routes defined by this gem:

```ruby
post 'callback', to: 'main#callback', as: :gateway_callback
get 'land', to: 'main#land', as: :gateway_back
```

The `gateway_callback` route will receive these callbacks from Barion Gateway. Every such message contains a `PaymentId` to identify which Payment has a state change. The gem is automatically tries to call a state refresh and get all the data of the payment from the Gateway.

You can call this manually too by issuing:

```ruby
payment.refresh_state
```

You can read more about this callback mechanism at <https://docs.barion.com/Callback_mechanism>.

#### Payment successful

When a payment is completed at the Barion Gateway it will automatically redirect the user back to your application. By default every payment request will held this redirect URL, which points to this gem's `:gateway_back` route.
You can change this however by setting the URL in the actual payment when creating it.

#### Payment failed

When a payment hasn't been completed if will eventually timeout at the Gateway. But if there was an issue of

### Error handling

The gem has a lightweight wrapper for errors that the Barion API reports.

When executing a payment (or in fact any other method which has an API call behind) an error can happen which the Barion API returns.

The gem will raise a ``::Barion::Error`` type exception when receives such error(s). If multiple errors are returned, the exception will have an `errors` property which will contains all errors in an array also wrapped by ``::Barion::Error``.

``::Barion::Error`` has the following properties:

```ruby
error = ::Barion::Error.new
error.title # Holds the value of Title attribute of the API error
error.message # Holds the value of Description attribute of the API error
error.error_code # Holds the value of ErrorCode attribute of the API error
error.happened_at # Holds the value of HappenedAt attribute of the API error
error.auth_data # Holds the value of AuthData attribute of the API error
error.endpoint # Holds the value of Endpoint attribute of the API error
```

### Security

When a payment has been sent to the gateway it will become readonly for Rails. Only the Gateway is allowed to change its state trough the callbacks.

To achieve this, a has is calculated for every payment when validating it. This hash will be stored in the DB and when a record is loaded in Rails it will be checked against the stored hash. If the hash does not match with the stored data a `::Barion::TamperedData` exception will be raised and the record will not be loaded. This basically mean that the data in the DB has been tampered outside this gem and cannot be considered financially safe.

## Contributing

We encourage you to contribute to this Barion gem!
To run tests:

1. Fork the repository
2. Check out your fork of this repo
3. Set up rbenv and add rbenv-vars as plugin
4. Set up your variables in .rbenv-vars like this:

    ```ruby
    CODECOV_TOKEN=<your token from Codecov.io>
    TEST_PAYEE=<your registered test shop email address at Barion>
    TEST_PIXEL_ID=<your test pixel id from Barion>
    TEST_POSKEY=<your test poskey from Barion>
    TEST_PUBKEY=<your test pubkey from Barion>
    ```

5. Run ``rails t`` to see if tests are working.
6. start modifying the code and run tests all the time.
7. Submit pull-request when done.

### Reporting issues or requesting features

This gem uses [GitHub Issue Tracking](https://github.com/meter-reader/barion/issues) to track issues (primarily bugs and contributions of new code). If you've found a bug  or have a good idea of a cool feature, this is the place to start. You'll need to create a (free) GitHub account in order to submit an issue, to comment on them, or to create pull requests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
