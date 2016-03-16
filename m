Content-Type: multipart/mixed; boundary="===============9093095365247892588=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 3/3] main: Safely free watch_data structures
Date: Wed, 16 Mar 2016 18:35:33 -0500
Message-ID: <56E9EDC5.3030803@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1603161550420.19388@mjmartin-mac01.wa.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9093095365247892588==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >>> be optimized (use a bitmap to flag which ones to free), but there's
>>> another problem: watch_list is indexed by an fd which was likely closed
>>> by the data->destroy() callback. It's possible for the fd to get re-used
>>> and a new watch to be created on that fd even before the data->destroy
>>> callback returns.
>>
>> But then won't you be calling the watch's callback erroneously anyway?
>> If this is a concern, then all new watches need to be postponed until
>> after the epoll processing has been completed.
>>
>
> No, the stale data is a pointer to watch_data not an fd value. By
> deferring the free we can make sure the event loop is calling something
> valid. The contents of watch_data can be reset however we need to. The
> problem is with pointer values stored in watch_list getting clobbered
> before they get used to free memory.

Now I get it.  I'm good with the proposed solution, but can we avoid =

having dummy callbacks?  Why not simply set the callback to zero (or set =

some flag) and not call it.

Regards,
-Denis

--===============9093095365247892588==--

