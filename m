Content-Type: multipart/mixed; boundary="===============7223778795669481920=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 12:55:36 -0500
Message-ID: <a4e39591-1aa5-4ce4-b2f4-4b9b896215bc@gmail.com>
In-Reply-To: <CAOq732++BS8+R3nHR_k5hwgM1D9412jh5bmtXKauQ2m5LOw00A@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7223778795669481920==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 07/20/2018 12:41 PM, Andrew Zaborowski wrote:
> On 20 July 2018 at 19:37, Andrew Zaborowski <andrew.zaborowski@intel.co=
m> wrote:
>> The loop is wrong though and would cause valgrind to complain because
>> after your last iteration ptr equals buf + len, so 'event' also points
>> at the end of buf and event->len is beyond the end of your buffer.
> =

> Uhh no, it's actually only checking that ptr < buf + len, I'm not
> reading correctly today.

Right.  The only thing it doesn't do is check that len >=3D sizeof(struct =

inotify_event).  But then I imagine you can trust the kernel to not =

screw this up.

I find the for loop version a bit more readable, but I'm okay applying =

your version as well.

Regards,
-Denis


--===============7223778795669481920==--

