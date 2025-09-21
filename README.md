# MomCare+ ![Development](https://img.shields.io/badge/Development-Active-brightgreen) ![Platform](https://img.shields.io/badge/Platform-iOS-blue) ![Static Badge](https://img.shields.io/badge/Active%20Branch-%22main%22-blue)

A personalized prenatal care app designed for expecting mothers. Offers health plans, milestone tracking, and expert tips to ensure a smooth journey through pregnancy. 

## Features

- **Multi-Platform Support**: iOS app, watchOS companion, Widget extension, and Intents extension
- **Cross-Target Code Sharing**: Comprehensive conditional compilation system for shared components
- **Health Integration**: HealthKit integration for health data tracking
- **Watch Connectivity**: Seamless communication between iOS and watchOS apps
- **Personalized Plans**: Customized pregnancy tracking and care plans

## Development

### Cross-Target Architecture

This project uses a sophisticated conditional compilation system to share code between multiple app targets while maintaining platform-specific functionality. See [`CONDITIONAL_COMPILATION_GUIDE.md`](CONDITIONAL_COMPILATION_GUIDE.md) for detailed information on:

- Platform detection and capability checking
- Framework availability checks
- Target-specific code organization
- Best practices for cross-target development

### Project Structure

- **MomCare** - Main iOS application
- **MomCare+Watch** - watchOS companion app
- **MomCare+PregnancyTracker** - WidgetKit extension
- **MomCare+Intents** - Intents extension
- **Common/** - Shared components with conditional compilation

## Backend

The Backend for this app is available at [**MomCare Backend**](https://github.com/rtk-rnjn/MomCare-Backend). The backend is under development. API endpoints and Models are available [**here**](http://13.233.139.216:8000/redoc).

## Recent activity [![Time period](https://images.repography.com/25054784/rtk-rnjn/MomCare/recent-activity/-DUsO2nKtYhOJ6rgHa36Wj_TgThRlXmDhY3PQPLEUWg/MQB_9DRqO1xmlH6N0JHhP0q2T0TWnArr4o4_c2kgRdA_badge.svg)](https://repography.com)
[![Timeline graph](https://images.repography.com/25054784/rtk-rnjn/MomCare/recent-activity/-DUsO2nKtYhOJ6rgHa36Wj_TgThRlXmDhY3PQPLEUWg/MQB_9DRqO1xmlH6N0JHhP0q2T0TWnArr4o4_c2kgRdA_timeline.svg)](https://github.com/rtk-rnjn/MomCare/commits)
[![Top contributors](https://images.repography.com/25054784/rtk-rnjn/MomCare/recent-activity/-DUsO2nKtYhOJ6rgHa36Wj_TgThRlXmDhY3PQPLEUWg/MQB_9DRqO1xmlH6N0JHhP0q2T0TWnArr4o4_c2kgRdA_users.svg)](https://github.com/rtk-rnjn/MomCare/graphs/contributors)

## More stats?

![Alt](https://repobeats.axiom.co/api/embed/b1bae23496c5d73f5f4a63e03c6cca7de9836f31.svg "Repobeats analytics image")
