# Makefile for Docker Compose

# Define default variables
DOCKER_COMPOSE = docker-compose
COMPOSE_FILE = docker-compose.yml


# Build the services defined in docker-compose.yml
build:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build

# Start the services in detached mode
up:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) $ up -d

# Stop and remove the containers
down:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

# Restart the services
restart:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) restart

# View the status of the containers
ps:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

# Clean up unused containers, volumes, and networks
prune:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans
