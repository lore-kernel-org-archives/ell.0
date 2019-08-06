Content-Type: multipart/mixed; boundary="===============4654022857248908921=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp-transport: fix out-of-bounds access
Date: Tue, 06 Aug 2019 15:14:37 -0500
Message-ID: <cbe5cd0c-f86f-407b-f5a1-4d2f3d31a898@gmail.com>
In-Reply-To: <20190806200849.2988-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4654022857248908921==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 8/6/19 3:08 PM, James Prestwood wrote:
> If len was odd the iovec was getting accessed out of bounds. 'j' needed
> to be decremented after the for loop. In addition, the iov_len was not
> being used to access the last byte of iov_base.
> ---
>   ell/dhcp-transport.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

Applied, thanks.

Regards,
-Denis


--===============4654022857248908921==--

