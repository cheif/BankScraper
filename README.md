BankScraper
===========

A ruby program for scraping bank-transactions and get a nice visualization of your expenses and income.

Setup
=====

To use, first create a user:

    $ ruby createaccountandget.rb <pnr> <pin>

This will create a user and fetch transactions, the scraper in swedbank.rb will probably have to be changed since it's connected to my specific account-structure.
Then fire upp the webserver:

    $ ruby webserver.rb

This should give you a nice interface, you will however need to create account (Konton -> Lägg till konto..) and categorize your transactions.
The interface will try to help you with the categorization through regex, these can also be added to the account.

When some transactions are categorized the graph should begin to populate and you will be able to see your accounts.

Supported banks
===============
[Swedbank](http://www.swedbank.se)

TODO
====
* Add more banks.
* Setup oAuth for multiple users
* Manage all settings from webinterface
* Add more graphs
