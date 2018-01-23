Content-Type: multipart/mixed; boundary="===============1367035786279293771=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/4] key: Add private API for key feature detection
Date: Tue, 23 Jan 2018 13:53:15 -0800
Message-ID: <alpine.OSX.2.21.1801231339480.14612@mjmartin-mac01.sea.intel.com>
In-Reply-To: <102756be-04a3-d3d8-2a49-0c810ab564d4@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1367035786279293771==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Tue, 23 Jan 2018, Denis Kenzior wrote:

> Hi Mat,
>
> On 01/23/2018 03:02 PM, Mat Martineau wrote:
>> The Diffie-Hellman, keyring restrictions, and key crypto parts of the
>> l_key API depend on kernel features that were added relatively
>> recently. While the affected l_key calls fail gracefully when the kernel
>> doesn't implement the required feature, they do not fail in a way that
>> allows unit tests to differentiate between library bugs and kernel
>> support. l_key_is_supported() is a private API to check for kernel
>> support.
>> ---
>>   ell/key-private.h | 27 +++++++++++++++++++++++++++
>>   ell/key.c         | 31 +++++++++++++++++++++++++++++++
>>   2 files changed, 58 insertions(+)
>>   create mode 100644 ell/key-private.h
>> =

>
> All applied, thanks!

I tested these changes out on various kernels going back to 4.2, and the =

keyctl feature detection worked fine.

I did run in to some glitches with test-pem and test-cipher on some old =

kernels. test-pem needs L_CIPHER_DES_CBC for encrypted certs, and =

test-cipher fails because AEAD ciphers had a bogus recv() return value =

before v4.9 (see kernel commit 0c1e16cd1e).

--
Mat Martineau
Intel OTC

--===============1367035786279293771==--

