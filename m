Content-Type: multipart/mixed; boundary="===============3465890484644473070=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau at linux.intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH] build: Check for openssl legacy provider requirement
Date: Fri, 20 May 2022 17:15:11 -0700
Message-ID: <4b908b7b-b273-53f1-942-d01be6484229@linux.intel.com>
In-Reply-To: 0373E38A-FD24-457D-B4DE-DFB4A9F91DCD@holtmann.org

--===============3465890484644473070==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 20 May 2022, Marcel Holtmann wrote:

> Hi Mat,
>
>> OpenSSL 3 introduced some command line incompatibilities and removed
>> some old algorithms from the defaults. This broke some of the unit test
>> cert generation commands on distros like Ubuntu 22.04 and Fedora 36.
>>
>> Detect support of "providers" by the system openssl command and insert
>> the necessary command line parameters to enable legacy algorithms for
>> openssl v3, but leave the commands unchanged for older openssl versions.
>> ---
>>
>> Tested on Ubuntu 22.04, Fedora 36, and Fedora 35.
>>
>> ---
>> Makefile.am  | 26 ++++++++++++++++++--------
>> configure.ac |  3 +++
>> 2 files changed, 21 insertions(+), 8 deletions(-)
>
> what would it take to just use OpenSSL 3 since these are just required =

> on the development systems. I need to check my release system since that =

> is historically always behind, but I feel this business of supporting =

> two OpenSSL versions will get out of hand quickly. It is too bad that we =

> can not generate the certificates with our own tools.

Well, that's slightly simpler: substitute "-provider legacy -provider =

default" to the commands in Makefile.am where I added $(openssl_legacy). =

It only cuts 9 lines out of the patch though.

These distros and OpenSSL 3 itself are still fairly new - as much as it =

seems like ELL gets used on older or limited systems the small =

compatibility effort seems worth it to me.

I'll send the OpenSSL3-only patch too and you can decide what direction =

to take.

--
Mat Martineau
Intel
--===============3465890484644473070==--

