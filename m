Content-Type: multipart/mixed; boundary="===============5963455158858773295=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/9] checksum: Refactor to remove loops and string
 operations
Date: Tue, 22 Jan 2019 11:36:31 -0600
Message-ID: <8565470d-a9c5-ef4b-832c-7a1eff0a7cc5@gmail.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5963455158858773295==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/22/2019 12:08 AM, Andrew Zaborowski wrote:
> Various checksum methods, like is_supported, get_digest_length, would
> look up the checksum data by building the algorithm name string and then
> iterating over all checksum_info structs to find the matching name.
> Change the checksum_info tables so that they're indexed by
> l_checksum_type and the lookups are cheap and simple.  Also drop the
> copies of the algorithm name from struct l_checksum.
> ---
> I've also tried changing l_checksum_get_digest_length to take a pointer
> to a checksum object instad of checksum type so it could be used equally
> for the primary algorithms and the HMAC and CMAC algorithms but iwd has
> one use case where it's convenient to have the digest size before
> creating the checksum object.
> ---
>   ell/checksum.c | 190 +++++++++++++++++++------------------------------
>   1 file changed, 73 insertions(+), 117 deletions(-)
> =


All applied, thanks.

Regards,
-Denis


--===============5963455158858773295==--

