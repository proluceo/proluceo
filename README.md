
# Proluceo - PostgreSQL Backend

Welcome to the PostgreSQL backend for **Proluceo**, an open-source ERP system. This backend serves as the core of Proluceo, encapsulating all business logic and ensuring robust, scalable, and efficient data management. It leverages the power of PostgreSQL and the custom build system [pg_builder](https://github.com/brunoenten/pg_builder/) designed for modular, structured, and maintainable database development.

## Features

- **Centralized Business Logic**: Implements all core business logic for Proluceo, ensuring consistent and reusable functionality.
- **Modular Architecture**: Organized using schemas and modules for clear separation of concerns.
- **Access Control**: Role-based permissions defined in SQL for secure data operations.
- **Scalability**: Designed to handle large datasets and complex transactions efficiently.
- **Open Source**: Fully open-source under the MIT License.

## Repository Structure

- `src/`: Contains the core database logic, including:
  - `permissions.sql`: Access control definitions.
  - `roles/`: Predefined roles and their associated permissions.
  - `schemas/`: Application-specific database schemas and logic.

- `pg_auth/`: Authentication configurations.

- Other files:
  - `Dockerfile`: Containerizes the backend for deployment.
  - `install.sh`: Installation script for setting up the backend.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/proluceo.git
   cd proluceo
   ```

2. Install PostgreSQL and ensure `pg_builder` is available:
   Follow the setup instructions for [pg_builder](https://github.com/brunoenten/pg_builder/).

3. Run the installation script:
   ```bash
   ./install.sh
   ```

4. Start the Docker container (optional):
   ```bash
   docker build -t proluceo-backend .
   docker run -d -p 5432:5432 proluceo-backend
   ```

## Contributing

We welcome contributions! Please fork the repository, create a new branch for your feature or bugfix, and submit a pull request.

### Development Notes

- Ensure all database logic adheres to the conventions established in `pg_builder`.
- Run tests locally using the `cucumber.yml` configuration.

## License

This project is licensed under the MIT License. See the [LICENSE.md](LICENSE.md) file for details.

## Resources

- [Proluceo Documentation](#)
- [pg_builder Documentation](https://github.com/brunoenten/pg_builder/)

## Contact

For questions or suggestions, please open an issue or reach out to the maintainers.

---

Thank you for contributing to Proluceo! Together, we're building the future of open-source ERP systems.
