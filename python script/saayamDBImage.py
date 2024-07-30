import subprocess

# Define variables
IMAGE_NAME = "sayalioak/saayam-database-image:latest"
CONTAINER_NAME = "saayam-db-container"
HOST_PORT = 3306  # Change as needed
CONTAINER_PORT = 3306  # Change as needed

# If you want to initialize the db with dummy data, insert the path to that sql file below
# SQL_SCRIPTS_DIR = os.path.abspath("path/to/your/sql/scripts")  # Local path


# CONTAINER_SCRIPTS_DIR="/docker-entrypoint-initdb.d"  # Default for MySQL

def run_command(command):
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")

def main():
    # Pull the Docker image
    print("Pulling Docker image...")
    run_command(f"docker pull {IMAGE_NAME}")

    # Remove any existing container with the same name
    print(f"Removing existing container (if any) with name {CONTAINER_NAME}...")
    run_command(f"docker rm -f {CONTAINER_NAME}")

    # Run the container
    print("Running the Docker container...")
    run_command(f"docker run -d --name {CONTAINER_NAME} -p {HOST_PORT}:{CONTAINER_PORT} {IMAGE_NAME}")

    # If you have SQL scripts to run, uncomment the following line and set the correct paths
    # print("Running the Docker container with SQL scripts...")
    # run_command(f"docker run -d --name {CONTAINER_NAME} -p {HOST_PORT}:{CONTAINER_PORT} -v {SQL_SCRIPTS_DIR}:{CONTAINER_SCRIPTS_DIR} {IMAGE_NAME}")

    print("Database container is up and running.")

    # Optional: Add a health check or wait time if the database takes time to start
    # time.sleep(10)  # Adjust as necessary

    print("Setup completed.")

if __name__ == "__main__":
    main()