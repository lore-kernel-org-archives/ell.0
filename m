Content-Type: multipart/mixed; boundary="===============4200185162053974148=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dhcp-server: Stricter start_ip/end_ip checks
Date: Wed, 03 Mar 2021 15:57:55 -0600
Message-ID: <ffc28b13-31d0-64de-4e96-eeecae56efbc@gmail.com>
In-Reply-To: <20210303213536.808395-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4200185162053974148==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/3/21 3:35 PM, Andrew Zaborowski wrote:
> Add basic checks that start_ip/end_ip are in the subnet defined by
> server->address and server->netmask.  Exclude server->address from
> allowed client addresses since we don't prohibit a start_ip/end_ip
> combination that contains server->address (and that's Ok).  Slightly
> modify how the default end_ip is derived from server->address to work
> with any prefix_length -- that seems to have been the only place that
> made assumptions about the prefix length.
> ---
>   ell/dhcp-server.c | 34 ++++++++++++++++++++++++++++++----
>   1 file changed, 30 insertions(+), 4 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis

--===============4200185162053974148==--

