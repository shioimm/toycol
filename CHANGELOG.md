# Changelog

All notable changes to this project will be documented in this file. For info on how to format all future additions to this file please reference [Keep A Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [1.0.0] - 2021-07-27

The first major release of Toycol.The main features are:

- [Added] Toycol::Protocol - For defining orignal application protocol
- [Added] Toycol::Proxy - For accepting requests and pass them to the background server
- [Added] Toycol::Command - For user friendly CLI
  - `$ toycol server` - For starting proxy & background server
  - `$ toycol client` - For sending request message to server
  - `$ toycol generate` - For generating skeletons of Protocolfile & application
- [Added] Toycol::Server - As a built-in background server
- [Added] Rack::Handler::Toycol - For running Rack compartible application & switching background server
