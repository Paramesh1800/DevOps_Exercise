from flask import Flask, request, jsonify
import boto3
import os

app = Flask(__name__)

TABLE_NAME = "Customer"

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

# Create Customer
@app.route('/customer', methods=['POST'])
def create_customer():
    data = request.json

    item = {
        "customer_id": data["customer_id"],
        "name": data["name"],
        "email": data["email"]
    }

    table.put_item(Item=item)

    return jsonify({
        "message": "Customer created"
    })

# Read Customer
@app.route('/customer/<customer_id>', methods=['GET'])
def get_customer(customer_id):

    response = table.get_item(
        Key={
            "customer_id": customer_id
        }
    )

    item = response.get("Item")

    if not item:
        return jsonify({"message": "Customer not found"}), 404

    return jsonify(item)

# Update Customer
@app.route('/customer/<customer_id>', methods=['PUT'])
def update_customer(customer_id):

    data = request.json

    table.update_item(
        Key={
            "customer_id": customer_id
        },
        UpdateExpression="SET #n=:name, email=:email",
        ExpressionAttributeNames={
            "#n": "name"
        },
        ExpressionAttributeValues={
            ":name": data["name"],
            ":email": data["email"]
        }
    )

    return jsonify({
        "message": "Customer updated"
    })

@app.route('/')
def home():
    return "DynamoDB Customer Service Running"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)