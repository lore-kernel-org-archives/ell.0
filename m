Content-Type: multipart/mixed; boundary="===============2487506405690845054=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: Debug logging with ell
Date: Wed, 25 Apr 2018 13:28:18 -0700
Message-ID: <CAPyD+=ADtj-MgqOHsptsXokepvHvdz+MSEKCuUg=oZLpBfqyAQ@mail.gmail.com>
In-Reply-To: <5ca4aed4-d944-8932-9208-209dd7d5f702@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2487506405690845054==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, Apr 25, 2018 at 1:23 PM, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/24/2018 11:33 AM, Stotland, Inga wrote:
>>
>> Quick question: can I use l_debug() when I am dynamically linking with
>> installed ell library (i.e., the one created with make install and
>> linked as -lell)?
>> Calling l_debug() generates no output, l_info() works just fine.
>
> So this should work now.  I've pushed a couple of fixes upstream.

Confirmed.  Debug logging works against a dynamically linked libell
for my use case.

Thanks!
-Ossama

--===============2487506405690845054==--

