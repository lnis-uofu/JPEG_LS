<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="http://1.bp.blogspot.com/-vm2DmP04b_0/V9LJ4c9_EEI/AAAAAAAAArc/eAgtSNkV0GUszzy9OlAUoJfbt_dX8UyEQCK4B/s1600/Screen%2BShot%2B2016-09-09%2Bat%2B9.39.53%2BAM.png" alt="Logo" width="1000" height="400">
  </a>

  <h3 align="center">JPEG-LS</h3>

  <p align="center">
    7 Stage Pipelined Hardware Implementation of Lossless Image Encoding
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
  * [Built With](#built-with)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)


<!-- ABOUT THE PROJECT -->
## About The Project

JPEG-LS is the standardization of the LOCO-I (LOw COmplexity LOssless COmpression for Images) algorithm at the core of the ISO/ITU T.87 standard. The ITU T.87 standard describes lossless and near-lossless compression of continuous-tone images. The algorithm is developed as a "low complexity implementation" of the standard universal context modeling paradign.

JPEG-LS is implemented as a simple fixed context modeling machine, which can compete with more complex implementations of universal techniques for capturing high-order dependencies of contextual information (ex. CABAC). The model of JPEG-LS is tuned for optimal performance jointly with limited-length Golomb-type codes. To increase compression standards, an embedded alphabet extension for coding of low-entropy image regions is deployed.

LOCO-I attains roughly a compression ratio of 3:1, which is similar or superior to encoding algorithms obtained with state-of-the-art schemes based off complex context modeling in conjuction with arithmetic coding. In addition, the complexity levels of the JPEG-LS implementation are exiguous when compared to state-of-the-art implementations.

JPEG-LS consists of three distinct and independent components:

<br><b>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  1) Prediction<br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  2) Context Modeling<br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  3) Coding<br>
<br></b>

### Built With
* Verilog
* MATLAB
* Python



<!-- GETTING STARTED -->
## Getting Started

All of the Verilog, MATLAB, and Python files needed for full integration and testing are located witin the Design Files folder.<br>
For a comprehensive design guide along with testing procedures refer to the <b><i> Lossless JPEG Design Guide </i></b> located in Design Files.

### Prerequisites

User will need Python3.7, Modelsim, and MATLAB to execute this deisgn.

### Installation

1. Clone the repo
```sh
git clone https://github.com/your_username_/Project-Name.git
```
2. Install Python3.7
3. Install Modelsim
4. Install MATLAB


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Grant Brown - grantb91@gmail.com
