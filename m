Content-Type: multipart/mixed; boundary="===============8908435031614941722=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 5/8] key: Add l_key_validate_dh_payload
Date: Wed, 09 Jan 2019 11:10:08 +0100
Message-ID: <CAOq732Kh_XmFywqMPdmUe=FNgDmq-Abdtfi8bzjf6f8PC8Krcg@mail.gmail.com>
In-Reply-To: <1a99f556-b8cd-2706-fe7a-8e1e9048d9e8@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8908435031614941722==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis

On Wed, 9 Jan 2019 at 04:19, Denis Kenzior <denkenz@gmail.com> wrote:
> On 01/07/2019 10:29 PM, Andrew Zaborowski wrote:
> > +     memcpy(prime_1, prime_buf, prime_len);
> > +
> > +     /* Produce prime - 1 for the payload < prime - 1 check */
> > +     while (pos && !prime_1[--pos]--);
> A prime is by definition odd, so isn't it sufficient to simply mask off
> the least significant bit instead of hand-coding a big-endian bignum
> subtract 1 operation?

True, that's simpler, I'll fix this.

> And seriously, my brain hurts from looking at this...

Just look at the comment instead :)

Best regards,

--===============8908435031614941722==--

