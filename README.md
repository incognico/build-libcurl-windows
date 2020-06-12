Auto download & compile libcurl
-----------
This batch script will automatically download the latest libcurl source code and build it using Visual Studio compiler.

libcurl is with as: **release-dll-zlib-static-ipv6-sspi-winssl-nghttp2-static** and features in `curl_disable.txt` are disabled

Supported Visual Studio are:
*  Visual Studio 2019
*  Visual Studio 2019 BuildTools

*Note-1*: All version of **Visual Studio express are unsupported**.

*Note-2*: This script is using third-party open source software
* `bin/7-zip` http://www.7-zip.org/download.html
* `bin/unxutils` http://sourceforge.net/projects/unxutils/
* `bin/xidel` http://sourceforge.net/projects/videlibri/files/Xidel/

Usage :

    $ build.bat

Output :

```
third-party
└───libcurl
    ├───include
    │   └───curl
    │           curl.h
    │           curlbuild.h
    │           curlrules.h
    │           curlver.h
    │           easy.h
    │           mprintf.h
    │           multi.h
    │           stdcheaders.h
    │           typecheck-gcc.h
    │
    └───lib
        ├───dll-release-x64
        │       libcurl.dll
        │
        └───dll-release-x86
                libcurl.dll
```

## FAQ
If you get message something like below, please re-run build.bat again.

    **** Retrieving:http://curl.haxx.se/download.html ****
    Downloading latest curl...
    http://curl.haxx.seAn unhandled exception occurred at $004C7D39 :: Bad port number.

License (build.bat)
-----------

    The MIT License (MIT)
    
    Copyright (c) 2014 Mohd Rozi
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
