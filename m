Content-Type: multipart/mixed; boundary="===============6933740179865892282=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Tue, 10 Feb 2015 13:47:58 -0600
Message-ID: <54DA606E.4010209@gmail.com>
In-Reply-To: <1423579344-10933-7-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6933740179865892282==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/10/2015 08:42 AM, Jukka Rissanen wrote:
> Allow user to remove and add values while inside a callback
> from foreach function. This is very much needed as it is
> easy to get things wrong here and it helps to avoid complicated
> call flows in calling applications.
>

Can you tell me why this is needed?  This sounds like abuse of =

hashmap_foreach and an alternate data structure might be in order.

> So foreach logic is changed so that if user tries to remove
> an entry from the hash while inside foreach callback, the
> entry is not yet removed from hash but marked as removable.
> After foreach has finished calling the callback function,
> it checks what elements it needs to remove from the hash.
>

So let me politely say: "No way are we doing this" ;)

> This valgrind report was seen and it relates to this issue.
> Here a DBus message was received and its callback function
> eventually called l_dbus_unregister() because of application
> logic. This then caused the signal_list hash to get corrupted
> because the unregister removed an entry from hash while
> traversing it.
>

So I think I understand why you're doing this...

l_dbus_register and l_dbus_unregister need to actually go away.  They =

are not workable long term.  We need a way smarter data structure to =

handle signal filtering.

Look at libsystemd/sd-bus/bus-match.c for some inspiration.

Regards,
-Denis

--===============6933740179865892282==--

