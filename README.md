# StoneApi

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Docker

To start the project in a docker/docker compose do this after clone:

  * `docker build -t stoneapi-app . && docker-compose up`
  
## Requests

  * Create User
  
    `curl --location --request POST 'http://localhost:4000/api/v1/sign_up' \
    --header 'Content-Type: application/json' \
    --data-raw '{
    	"user": {
    		"email": "filosofisto@gmail.com",
    		"password": "socrates",
    		"password_confirmation": "socrates"
    	}
    }'`
    
    This request will create a user and authenticated him, and returns a JSON 
    like that bellow:
    
    `{
         "jwt": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzdG9uZUFwaSIsImV4cCI6MTU4MTA4NzgxOSwiaWF0IjoxNTc4NjY4NjE5LCJpc3MiOiJzdG9uZUFwaSIsImp0aSI6IjA2ZmI2MWFhLTVjYWUtNDQzNy1iODM4LWMyMjk4ZWFmMTdiMSIsIm5iZiI6MTU3ODY2ODYxOCwic3ViIjoiMyIsInR5cCI6ImFjY2VzcyJ9.QLeymshyA-BIJHX9uG9DKIoOSXHW1TOZIZ7Dzv7ZsPpiDzT1rsU-Zf6mxkBKQZfm0NBP6EunxgPU9jQHBMUT3Q"
     }`
     
     This token must be used in all authenticated requests.
      
  * Authentication
  
    `curl --location --request POST 'http://localhost:4000/api/v1/sign_in' \
    --header 'Content-Type: application/json' \
    --data-raw '{
    	"email": "filosofisto@gmail.com",
    	"password": "socrates"
    }'`
    
    This request will authenticate the user, and returns a JSON like that bellow:
        
    `{
             "jwt": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzdG9uZUFwaSIsImV4cCI6MTU4MTA4NzgxOSwiaWF0IjoxNTc4NjY4NjE5LCJpc3MiOiJzdG9uZUFwaSIsImp0aSI6IjA2ZmI2MWFhLTVjYWUtNDQzNy1iODM4LWMyMjk4ZWFmMTdiMSIsIm5iZiI6MTU3ODY2ODYxOCwic3ViIjoiMyIsInR5cCI6ImFjY2VzcyJ9.QLeymshyA-BIJHX9uG9DKIoOSXHW1TOZIZ7Dzv7ZsPpiDzT1rsU-Zf6mxkBKQZfm0NBP6EunxgPU9jQHBMUT3Q"
     }`
         
     This token must be used in all authenticated requests.
     
  * Withdrawal
  
    `curl --location --request POST 'http://localhost:4000/api/v1/withdrawal' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzU...' \
    --data-raw '{
    	"value": 1.0
    }'`
    
    
    
  * Transfer
  
    `curl --location --request POST 'http://localhost:4000/api/v1/transfer' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzU...' \
    --data-raw '{
    	"financial_account_target_id": 14,
    	"value": 45.0
    }'`
    
    This operation will transfer <value> from account of logged user
    to account identified by <financial_account_target_id>. 
    
    As the business rule points, the origin account must have enough ballance.
    
  * Report
  
    For get the report with total of transactions, total by year, by month and
    by day, and yet all transactions (bonus) just point your browser to
    http://localhost:4000/web/v1/report 
    and be happy!
              
## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
