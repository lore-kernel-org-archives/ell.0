Content-Type: multipart/mixed; boundary="===============8096599664888878483=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] pkcs5: Fix pbes2 KDF parsing
Date: Thu, 17 Aug 2017 12:09:12 -0500
Message-ID: <79cdb003-51c1-af50-3e0f-31ceda9ab248@gmail.com>
In-Reply-To: <20170817090631.27630-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8096599664888878483==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/17/2017 04:06 AM, Andrew Zaborowski wrote:
> Make the key length field optional -- skip if the tag doesn't match --
> and fix the oid comparison.
> ---
>   ell/pkcs5.c | 20 +++++++++++---------
>   1 file changed, 11 insertions(+), 9 deletions(-)
> =


All three applied, thanks.

Regards,
-Denis


--===============8096599664888878483==--

