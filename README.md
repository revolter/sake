# Sake - Swift Make

[![Build Status](https://travis-ci.org/xcodeswift/sake.svg?branch=master)](https://travis-ci.org/xcodeswift/sake)

Sake is a Swift command line tool that helps you automate tasks in your projects. It's heavily inspired by [Makefile](https://en.wikipedia.org/wiki/Makefile) and [Rake](https://github.com/ruby/rake).

## Motivation 💅

Why automating tasks using shell scripting or Ruby when you can do it in Swift, a language you are already familiar with?
Sake aims to provide a command line tool and the foundation to automate your tasks in Swift.

## Installation 🥑

You can easily install rake using [Homebrew](https://brew.sh/):

```
brew tap xcodeswift/sake git@github.com:xcodeswift/sake.git
brew install sake
```

## Setup ⚒

1. Git clone the project `git clone git@github.com:xcodeswift/sake.git`.
2. Build `swift build`.

## Sakefile

Sakefile is the file that defines your project tasks:

```swift
// Sakefile
import SakefileDescription

Sake {
    $0.task(name: "clean", description: "cleans the project build directory", action: { (_) in
        // Cleans the build directory
    })
    $0.task(name: "build", description: "builds the project", dependencies: ["clean"], action: { (_) in
        // Builds the project
    })
    $0.task(name: "test", description: "tests the project", dependencies: ["clean"], action: { (_) in
        // Test the project
    })
}.run()
```

## Usage

#### Creating a Sakefile.swift
You can create an empty `Sakefile.swift` running the following command:

```bash
sake init
```

#### Working on the Sakefile.swift
You can edit the `Sakefile.swift` using any text editor. Nonetheless, we recommend you to use Xcode since you'll get syntax highlighting and code autocompletion for free. Sake provides a command to generate the Xcode project where you can edit the `Sakefile.swift`. You can generate the command by running:

```bash
sake generate-xcodeproj
```

> :warning Note: Xcode can only run Swift code in a `main.swift` file. Since the name of the file is `Sakefile.swift` you'll get some Xcode warnings. Ignore them!

#### Tasks

##### Run a task

```bash
sake task name_of_the_task
```

##### List all the tasks

```bash
sake tasks
```


## License

```
MIT License

Copyright (c) 2017 xcode.swift

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
