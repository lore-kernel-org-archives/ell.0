Content-Type: multipart/mixed; boundary="===============5384619929984311552=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] key: Change initialization of struct keyctl_dh_params
Date: Tue, 25 Sep 2018 09:26:24 -0700
Message-ID: <alpine.OSX.2.21.1809250919480.17067@kvwoan-mobl2.amr.corp.intel.com>
In-Reply-To: <1f1a0849-94f5-7538-8f1f-f07240118b7c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5384619929984311552==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Thu, 20 Sep 2018, Denis Kenzior wrote:

> Hi Mat,
>
> On 09/20/2018 06:14 PM, Mat Martineau wrote:
>> Using a designated initializer with struct keyctl_dh_params has broken
>> due to a kernel header file change to one of the member names,
>> introduced in kernel v4.19-rc3:
>> =

>> https://lore.kernel.org/lkml/1735b3a4-2792-0ce4-3bf4-94fee5b50ff6(a)infr=
adead.org/
>> =

>> If the member names are dropped from the initializer then the code will
>> compile and work correctly before or after the kernel header change.
>> ---
>
> Applied, thanks.

The good news is that the kernel change causing this headache has been =

reverted for the upcoming v4.19-rc6.

The bad news is that it found its way in to v4.14.{70,71} and v4.18.{8,9}. =

The revert was cc'd to stable (but I don't see them in stable-queue yet).

--
Mat Martineau
Intel OTC

--===============5384619929984311552==--

