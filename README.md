This project contains globally useful, portable includes for augmenting the base functionality of the proprietary AMX NetLinx language used for programming [AMX NetLinx integrated controllers](http://www.amx.com/products/categoryCentralControllers.asp).

Currently the project provides a math library, string manipulation library, time and date library, array utils, a managed debug messaging library and an associated console output library.

# Contributors
[Kim Burgess](http://kimburgess.info)

[true](mailto:amx@trueserve.org)

[Jeff Spire](http://spireintegrated.com/)

[Jorde Vorstenbosch](mailto:jordevorstenbosch@gmail.com)

[Andy Dixon](https://github.com/PsyenceFact)

[Motaz Abuthiab](mailto:moty66@gmail.com)

# Contributing

Want to help out? Awesome.

1. Fork it.
2. Make your changes / improvements / bug fixes etc (and ensure that you adhere to the [project style guide](https://github.com/KimBurgess/NetLinx-Common-Libraries/wiki/Code-Format-and-Commenting) whilst doing so).
3. Submit a pull request.
4. Win.

# Usage

A convenience include has been provided to simplify usage. Ensure that the libraries are placed within your project's compile path then include prior to utilizing provided functionality within your project code.

    include 'netlinx-common-libraries'

Alternatively, individually specify the library components that you require. Any cross include dependencies within the NetLinx Common Libraries are handled internally.

This project is licensed under the MIT License. Feel free to use it, sell it, modify it, re-distribute - basically whatever the hell you like. See [LICENSE](https://github.com/KimBurgess/NetLinx-Common-Libraries/blob/master/LICENSE) for more info.
