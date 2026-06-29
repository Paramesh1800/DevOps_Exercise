# Exercise 23: Flask CI/CD Pipeline with GitHub Actions & ECR

This project demonstrates a Python Flask web application integrated with a CI/CD pipeline using **GitHub Actions**, containing unit tests with **pytest**, and configured to build and push Docker images to **Amazon ECR**.

---

## Project Structure

```text
Exercise-23/
├── app.py             # Flask application entrypoint
├── test_app.py        # Pytest unit tests
├── requirements.txt   # Python dependencies
├── Dockerfile         # Docker container configuration
└── README.md          # Project documentation
```

---

## Getting Started

### Prerequisites

- Python 3.12+
- Docker (optional, for containerized running)

### Local Setup

1. **Create and activate a virtual environment:**
   ```bash
   python -m venv venv
   # On Windows:
   venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the Flask application:**
   ```bash
   python app.py
   ```
   The application will start on `http://localhost:5000`.

---

## Running Unit Tests

This project uses `pytest` for unit testing. To run the tests locally, run:

```bash
pytest
```

---

## Docker Containerization

1. **Build the Docker image:**
   ```bash
   docker build -t flask-app:latest .
   ```

2. **Run the container:**
   ```bash
   docker run -p 5000:5000 flask-app:latest
   ```

---

## CI/CD Pipeline (GitHub Actions)

The workflow file is located at the root of the repository under `.github/workflows/ci-cd.yml` and triggers on pushes to the `master` branch.

### Pipeline Stages

1. **Checkout & Setup**: Clones the repository and sets up Python 3.12.
2. **Install Dependencies**: Installs the dependencies from `requirements.txt`.
3. **Run Unit Tests**: Runs the test suite via `pytest`.
4. **AWS Authentication**: Configures AWS credentials using repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
5. **Amazon ECR Login**: Authenticates Docker to Amazon ECR.
6. **Build, Tag, & Push**: Builds the Docker image, tags it as `latest`, and pushes it to Amazon ECR.
