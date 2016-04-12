Content-Type: multipart/mixed; boundary="===============0839068234456237434=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 01/11] dbus: Validate field type in get_header_field
Date: Tue, 12 Apr 2016 13:51:55 -0500
Message-ID: <570D43CB.7030103@gmail.com>
In-Reply-To: <1460426175-25501-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0839068234456237434==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/11/2016 08:56 PM, Andrew Zaborowski wrote:
> It seems there's no place where we are validating the header
> fields of incoming messages so let's do it here.
> ---
>   ell/dbus-message.c | 35 ++++++++++++++++++++---------------
>   1 file changed, 20 insertions(+), 15 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============0839068234456237434==--

