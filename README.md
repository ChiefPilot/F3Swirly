F3Swirly
========

Welcome!
--------
This demo contains the "swirly" control for iOS.   It has been
tested on iOS 4.x and 5.x on iTouch, iPhone, and iPad devices.

![Screenshot](https://raw.github.com/ChiefPilot/F3Swirly/master/F3Swirly.png "Screenshot of Component Demo App")

If you find this control of use (or find bugs), I'd love to hear
from you!   Drop a note to brad@flightiii.com with questions, comments, 
or dissenting opinions.


Background
----------
I needed a control which had visual aspects of both an  activity 
indicator as well as an annunciator.    This control satisfies that
need by providing, textual, color, and animated feedback.  

The control uses Quartz 2D and Core Animation to provide a reasonable
level of performance with virtually no CPU overhead required for the 
animation.    The number of segments, segment color, segment thickness, 
rotation rate, and text can all be customized.   


Usage
-----
Adding this control to your XCode project is straightforward:

1. Add the F3Swirly.h and F3Swirly.m files to your project
2. Add a new blank subview to the nib, sized and positioned to match what the bar gauge should look like.
3. In the properties inspector for this subview, change the class to "F3Swirly"
4. Add an outlet to represent the control
5. Add thresholds to describe the color, number of segments, textual label, etc. as needed.   See the demo code for an example of how this is done.
6. Update your code to set the value property as appropriate.


Tips
----
- Specifying a negative integer for rotation rate will result in 
counter-clockwise rotation, while positive integers will result in
clockwise rotation.
- Specifying zero for the number of segments will result in only the
label being shown.
- Specifying nil for the label for a specific threshold will result in 
no text being shown.


License
-------
Copyright (c) 2012 by Brad Benson
All rights reserved.
  
Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following 
conditions are met:
  1.  Redistributions of source code must retain the above copyright
      notice this list of conditions and the following disclaimer.
  2.  Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in 
      the documentation and/or other materials provided with the 
      distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
OF SUCH DAMAGE.
