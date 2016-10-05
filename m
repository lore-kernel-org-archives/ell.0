Content-Type: multipart/mixed; boundary="===============0482163290513473292=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: ELL API changes before stabilizing
Date: Wed, 05 Oct 2016 14:45:03 -0700
Message-ID: <alpine.OSX.2.20.1610051332130.26281@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0482163290513473292==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


We will soon reach a point where breaking changes to the ELL APIs will get =

a lot more painful - changes already create a headache for the handful of =

projects we know about. Given that, I took a look over the public headers =

to see if there were any obvious adjustments to be made, and only found a =

few issues that jumped out at me.


1. timeout: extra nanosecond APIs with extremely_long_function_names. We =

could scrap the *_with_nanosecond calls and include nanoseconds in =

l_timeout_create and l_timeout_modify.


2. timeout: Why not use time_t for seconds? Yeah, 4 billion seconds should =

be enough for anyone, but the same argument could be made for the =

underlying struct timespec that's used for the system calls.


3. main: We recently changed l_main_exit() to be a cleanup function. It =

used to trigger an exit action. It would be more consistent to name the =

function for what it does rather than when it should be run =

(l_main_cleanup()?).


4. uintset: Why does uintset_new() create a set with min =3D=3D 1? C =

programmers are more likely to assume it's 0-indexed. Maybe we don't need =

both l_uintset_new and l_uintset_new_from_range. One function that takes =

min and max seems sufficient.


Anything else you've noticed?

--
Mat Martineau
Intel OTC

--===============0482163290513473292==--

