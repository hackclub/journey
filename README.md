# Journey
A 3 week journey into making!

## Developing locally
1. Make sure you have PostgreSQL running locally.
2. Run `bin/rails db:prepare` to prepare the database.
3. Copy `.env.example` to `.env` and populate the values
NOTE: You have to give the bot the following scopes: \
`channels:history`, `chat:write`, `groups:history`, `im:write`, `reactions:write`, `users.profile:read`, `users:read`, `users:read.email`, `im:history`, `im:read`.
4. Comment out any airtable refrence from `app/models/user.rb`, unless you have access to the journey airtable. (make sure to not include that file when contributing)
5. Run `bin/dev` to start the development server, it will run on port 3000.

