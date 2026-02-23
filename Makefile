DATA_DIR	= /home/yahyalb/data

all:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@docker system prune -af
	@docker volume prune -f

fclean: clean
	@sudo rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

re: fclean all

.PHONY: all down clean fclean re