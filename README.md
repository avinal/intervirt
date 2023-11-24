# intervirt
An interactive learning environment built on top of kube-virt.

Intervirt is an open-source project aimed at providing a platform for running interactive Kubernetes tutorials in a self-hosted environment. This project seeks to fill the gap left by the monetization of previously free platforms, offering users the freedom and flexibility to learn Kubernetes without incurring costs.


## Table of Contents

- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)


### Introduction

Intervirt is developed with a Golang backend and Elm frontend, focusing on ease of use and extensibility. Users can input tutorial links, and Intervirt will run these tutorials locally on the user's machine.

### Project Structure

Intervirt's codebase is organized into two main directories:

- backend/: Contains the Golang code, responsible for the server-side logic, API endpoints, and integration with kubevirt for VM creation.
    - cmd/: Entry point of the application.
    - pkg/: Core packages for the application, including API, controller, models, and service logic.
- frontend/: Developed in Elm, this directory manages the user interface components of the application.

### Installation

TODO: Add installation instructions

### Usage

TODO: Add usage instructions

### Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

1. Fork the Project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

### License

Distributed under the Apache 2.0 License. See [LICENSE](./LICENSE) file for more information.

