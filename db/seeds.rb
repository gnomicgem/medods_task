# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.where(
  guid: "123e4567-e89b-12d3-a456-426614174000",
  name: "John Doe",
  email: "john.doe@email.com"
).first_or_create
