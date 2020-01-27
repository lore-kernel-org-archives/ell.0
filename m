Content-Type: multipart/mixed; boundary="===============1095166579439384030=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] unit: Add test-casese for l_ringbuf_append function
Date: Mon, 27 Jan 2020 14:37:08 -0600
Message-ID: <16d6ddb7-e4b7-84bf-06e9-a08de640359f@gmail.com>
In-Reply-To: <20200127065331.8980-1-przemyslaw.fierek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1095166579439384030==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Przemys=C5=82aw,

On 1/27/20 12:53 AM, Przemys=C5=82aw Fierek wrote:
> This patch adds unit-tests for previously submitted `l_ringbuf_append`
> function. Second version contains fixes from the code review.

The second sentence is really a change log / metadata and should not be =

in the commit description.  Put such stuff where it belongs: after '---'...

> =

> ---
>   unit/test-ringbuf.c | 86 ++++++++++++++++++++++++++++++++++++++++++++-
>   1 file changed, 85 insertions(+), 1 deletion(-)
> =


...in other words: here

<snip>

> +static void test_append2(const void *unused)
> +{
> +	static const uint8_t expected_data1[14] =3D {3, 4, 5, 6, 1, 2, 3, 4, 5,
> +					    6, 1, 2, 3, 4};

No mixed tab & space indentation please.  Always use tabs.  Also, we =

prefer space after '{' and before '}'.

Applied after slight wordsmithing of the commit description and minor =

coding style cleanups.

Regards,
-Denis
--===============1095166579439384030==--

