Content-Type: multipart/mixed; boundary="===============7793007382081730104=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] hwdb: Allow loading of v2 or v3 hwdb.bin files
Date: Fri, 07 Sep 2018 15:44:15 -0500
Message-ID: <e0f873b8-2333-4cbd-f768-0bfd36ed8e3c@gmail.com>
In-Reply-To: <20180907201250.17651-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7793007382081730104==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 09/07/2018 03:12 PM, Mat Martineau wrote:
> The hwdb trie entry has been extended in a reverse-compatible way, but
> ELL had a strict check for the size of struct trie_entry that caused the
> load to fail. Instead of requiring an exact size, only make sure the
> entry is not too small.
> ---
>   ell/hwdb.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

All applied, thanks.

Regards,
-Denis


--===============7793007382081730104==--

