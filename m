Content-Type: multipart/mixed; boundary="===============2406090073850538896=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Better search for matching rules in the filter
 tree
Date: Tue, 03 May 2016 14:09:26 -0500
Message-ID: <5728F766.4010008@gmail.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2406090073850538896==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/28/2016 10:31 PM, Andrew Zaborowski wrote:
> When adding new filter rules, perform a more complete search for
> existing rules that already cover the rule being added by removing the
> requierement that levels in the tree are ordered by the match type.
> This may add overhead to adding new rules in some situations but will
> reduce the number of server-side rules being used and the number of
> requests.  This covers a scenario where first a watch is added for:
>
> type=3Dsignal, path=3D/
>
> followed by
>
> type=3Dsignal, sender=3Dorg.test, path=3D/
>
> I believe there are some more tricky scenarios which are not covered
> specifically when more than one child of an existing node matches some
> condition of the rule being added.
> ---
>   ell/dbus-filter.c  | 67 +++++++++++++++++++++++++++++++++++++++++++----=
-------
>   ell/dbus-private.h |  8 +++----
>   2 files changed, 58 insertions(+), 17 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============2406090073850538896==--

