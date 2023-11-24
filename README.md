# intervirt
An interactive learning environment built on top of kube-virt.

Intervirt is an open-source project aimed at providing a platform for running interactive Kubernetes tutorials in a self-hosted environment. This project seeks to fill the gap left by the monetization of previously free platforms, offering users the freedom and flexibility to learn Kubernetes without incurring costs.


## Table of Contents

- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Value Proposition: Why Self-Hosted?](#value-proposition-why-self-hosted)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)


### Introduction

Intervirt is developed with a Golang backend and Elm frontend, focusing on ease of use and extensibility. Users can input tutorial links, and Intervirt will run these tutorials locally on the user's machine.

### Value Proposition: Why Self-Hosted?

- Cost-Effectiveness: The primary appeal is cost savings. Services like Katacoda or Killer Koda charge for access to their infrastructure, which hosts the interactive environments. By contrast, a self-hosted solution eliminates or significantly reduces these costs, as users utilize their own hardware or cloud instances.

- Customizability and Control: Users have complete control over the environment. They can customize the setup, choose specific versions of tools and software, and tweak the system to their preferences or needs.

- Privacy and Security: In a self-hosted environment, sensitive data and configurations remain within the user's control, offering enhanced privacy and security compared to using a third-party hosted service.

- Learning and Educational Value: Setting up and maintaining a self-hosted platform can provide valuable learning experiences, especially for users interested in the technical aspects of Kubernetes and virtualization.

- No Vendor Lock-in: Users are not tied to the policies, pricing, or availability of a specific vendor. They can modify, extend, or migrate their setup as they see fit.

- Community and Open Source Benefits: As an open-source project, Intervirt can benefit from community contributions, leading to a diverse range of features and improvements over time.

- Offline Access: Users can access their environments without an internet connection, which can be useful for users with limited or unreliable internet access.

- Performance: Self-hosted environments can offer better performance than hosted solutions, as users can choose their own hardware or cloud instances.

- Scalability: Users can scale their environments to their needs, without being limited by the policies or pricing of a third-party service.

- Ease of Use: Intervirt aims to be easy to use, with a simple interface and minimal setup required.

- Flexibility: Users can run any tutorial they want, without being limited to the tutorials offered by a third-party service.

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

