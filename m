Content-Type: multipart/mixed; boundary="===============5296119933650178584=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Przemys=C5=82aw?= Fierek <przemyslaw.fierek@silvair.com>
Subject: Re: [PATCH v2] unit: Add test-casese for l_ringbuf_append function
Date: Tue, 28 Jan 2020 10:54:46 +0100
Message-ID: <4197d6b7-8c8d-75d2-bdb1-ff38f2386804@silvair.com>
In-Reply-To: <16d6ddb7-e4b7-84bf-06e9-a08de640359f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5296119933650178584==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,


Thank you for review. I will keep in mind your recommendations when I =

will want to submit another patches.


Regards,

Przemek


On 27.01.2020 21:37, Denis Kenzior wrote:
> Hi Przemys=C5=82aw,
>
> On 1/27/20 12:53 AM, Przemys=C5=82aw Fierek wrote:
>> This patch adds unit-tests for previously submitted `l_ringbuf_append`
>> function. Second version contains fixes from the code review.
>
> The second sentence is really a change log / metadata and should not =

> be in the commit description.=C2=A0 Put such stuff where it belongs: afte=
r =

> '---'...
>
>>
>> ---
>> =C2=A0 unit/test-ringbuf.c | 86 ++++++++++++++++++++++++++++++++++++++++=
++++-
>> =C2=A0 1 file changed, 85 insertions(+), 1 deletion(-)
>>
>
> ...in other words: here
>
> <snip>
>
>> +static void test_append2(const void *unused)
>> +{
>> +=C2=A0=C2=A0=C2=A0 static const uint8_t expected_data1[14] =3D {3, 4, 5=
, 6, 1, 2, 3, =

>> 4, 5,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 6, 1,=
 2, 3, 4};
>
> No mixed tab & space indentation please.=C2=A0 Always use tabs. Also, we =

> prefer space after '{' and before '}'.
>
> Applied after slight wordsmithing of the commit description and minor =

> coding style cleanups.
>
> Regards,
> -Denis
--===============5296119933650178584==--

