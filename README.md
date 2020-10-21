<br />
<p align="center">
  <h3 align="center">AdAdapted Swift iOS SDK</h3>

  <p align="center">
    New swift edition of the iOS SDK for AdAdapted.
    <br />
    <a href="https://docs.adadapted.com/#/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://gitlab.com/adadapted/ios_swift_sdk/-/issues">Report Bug</a>
    ·
    <a href="https://gitlab.com/adadapted/ios_swift_sdk/-/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
* [CoCoa Pod](#cocoa-pod)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)


<!-- ABOUT THE PROJECT -->
## About The Project

This SDK is used for implementing the AdAdapted ad views, keyword interception, ad event tracking, and deeplinking features.

Here's a blank template to get started:
**To avoid retyping too much info. Do a search and replace with your text editor for the following:**
`github_username`, `repo_name`, `twitter_handle`, `email`

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running simply download the source code and run it through one of the target sample apps (SwiftExample and ObjcExample). You'll also need to input your own API key in the example app AppDelegates respectively. After that, you should start seeing ads and intercepts on the following 'List Page' of the sample apps (assuming your API key has a corresponding ad campaign enabled).

```sh
AASDK.startSession(withAppID: "YOUR_API_KEY", registerListenersFor: self, options: options)
```

<!-- COCOA POD -->
### CoCoa Pod

Alternatively the SDK is available via CoCoa Pod and can be directly imported and used within your own apps. 

Once you have CoCoa Pods installed and integrated with your project, you can udpate your podfile to include the 'AASwiftSDK' pod:

```sh
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AASwiftExampleApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'AASwiftSDK'

end
```

Then after opening the .xcworkspace version of your project, you should see the newly imported AASwiftSDK within your project structure.

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (using conventional commits [https://www.conventionalcommits.org/en/v1.0.0-beta.4/]) (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<!-- LICENSE -->
## License

See `LICENSE` for more information.

<!-- CONTACT -->
## Contact

Brett Clifton - [bclifton@adadapted.com]


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/github_username/repo.svg?style=flat-square
[contributors-url]: https://github.com/github_username/repo/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/github_username/repo.svg?style=flat-square
[forks-url]: https://github.com/github_username/repo/network/members
[stars-shield]: https://img.shields.io/github/stars/github_username/repo.svg?style=flat-square
[stars-url]: https://github.com/github_username/repo/stargazers
[issues-shield]: https://img.shields.io/github/issues/github_username/repo.svg?style=flat-square
[issues-url]: https://github.com/github_username/repo/issues
[license-shield]: https://img.shields.io/github/license/github_username/repo.svg?style=flat-square
[license-url]: https://github.com/github_username/repo/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/github_username
[product-screenshot]: images/screenshot.png