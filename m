Content-Type: multipart/mixed; boundary="===============1194643585115350927=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/4] key: Add private API for key feature detection
Date: Tue, 23 Jan 2018 16:36:39 -0800
Message-ID: <alpine.OSX.2.21.1801231442540.14612@mjmartin-mac01.sea.intel.com>
In-Reply-To: <f42d9603-59eb-861b-58a4-558119f2084c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1194643585115350927==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Tue, 23 Jan 2018, Denis Kenzior wrote:

>> I did run in to some glitches with test-pem and test-cipher on some old =

>> kernels. test-pem needs L_CIPHER_DES_CBC for encrypted certs, and =

>
> I've just pushed out an update to test-pem that hopefully takes care of t=
his.

It worked with my old 4.2 kernel.

>> test-cipher fails because AEAD ciphers had a bogus recv() return value =

>> before v4.9 (see kernel commit 0c1e16cd1e).
>
> Not sure what we can do about this one.

We could print a more descriptive message for that failure, so people at =

least have a hint about what's going on.

Only other idea I have is to attempt a crypto op and compare against a =

known-bad result. While the results before v4.9 are wrong, I think they're =

at least consistent.


I will send a couple more patches for AEAD failure handling and unit =

test issues that I noticed.

--
Mat Martineau
Intel OTC

--===============1194643585115350927==--

