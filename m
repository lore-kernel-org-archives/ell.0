Content-Type: multipart/mixed; boundary="===============9202674497673915619=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Wed, 29 May 2019 03:04:48 +0000
Message-ID: <AD071452-7D69-4328-9464-651E0C029DA6@intel.com>
In-Reply-To: <77166303-c2ea-5822-e36a-d52517e79840@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9202674497673915619==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

> On May 28, 2019, at 6:32 PM, Denis Kenzior <denkenz@gmail.com> wrote:
> =

> Hi Brian,
> =

>> On 05/28/2019 07:49 PM, Brian Gix wrote:
>> The algorythm is supported in the kernel, and it is used heavily by
>> Bluetooth Mesh, and is the one Mesh required algorythm missing from ELL.
>> ---
>>  ell/cipher.c       | 88 +++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>>  ell/cipher.h       | 16 ++++++++++
>>  unit/test-cipher.c | 74 +++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 178 insertions(+)
> =

> Please be aware of our patch submission guidelines found in HACKING. E.g.=
 the unit test should be in a separate commit.
> =

> Have you checked whether l_checksum_new_cmac_aes() satisfies your needs?

I didn=E2=80=99t see that. I will check it out, and if it works, I will wit=
hdraw my patch altogether. If it does not work, I will resubmit as a patch-=
set.

> =

> Regards,
> -Denis

--===============9202674497673915619==--

