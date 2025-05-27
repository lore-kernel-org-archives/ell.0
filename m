Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABF35280328
	for <ell@lists.linux.dev>; Tue, 27 May 2025 18:16:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748369783; cv=none; b=l9iPw106axySrlkFfX0CYS3gg71n0NWUrvePvGP3Bf1ha4p+O+6J2tR0nPRFk6O8Nq18G/KvG2GGpCmvgWGAJClCUDi7hqUiTQcLSSLn/gw5prS8mHBpPzFlSevk6y5GzyXopQDyqV2tjjGf5FQPLmAIR4AiiItNmi9nBq2kL2U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748369783; c=relaxed/simple;
	bh=UDA4+tyttwNzLH0+s3Fg1Fa/D+dp9EEuXpcPNYE4nak=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=g1CtYRWtr8k3ao7w0I8aL1kEiigBm7t1KeV5TpYZrKtQEeGnMMan0P9ZaUR4GIAfjJt311RbrdTVam3mm67FyczvAnDOZW7rfN0IUyrqut6uo6CyFuhcK6K+w5V79PicLFgfqyM2L+hOfbPBnxTOEYUZbw12TlrLDt/miSjeLr8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=AgeaJZAu; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="AgeaJZAu"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id C2DA2164A45;
	Tue, 27 May 2025 14:08:17 -0400 (EDT)
Received: from smtpclient.apple (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 6823E124E50;
	Tue, 27 May 2025 14:08:17 -0400 (EDT)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.600.51.1.1\))
Subject: Re: [PATCH v9 0/9] Input/Output Terminal Abstraction
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <9E228E49-412C-478B-AD92-F8FA2210BFDD@holtmann.org>
Date: Tue, 27 May 2025 11:08:06 -0700
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <748F73CA-FB10-43BC-969F-0D497C4605E9@nuovations.com>
References: <cover.1743976923.git.gerickson@nuovations.com>
 <9E228E49-412C-478B-AD92-F8FA2210BFDD@holtmann.org>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3826.600.51.1.1)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=content-type:mime-version:subject:from:in-reply-to:date:cc:content-transfer-encoding:message-id:references:to; s=pair-202401062137; bh=4VlVxbvP64LsrfjGT2rlghcvBrkfD6PbHG4rfRxUwp8=; b=AgeaJZAutIiChcGMVReuE4KWYZTwmyojcSN3WHOKWCFDn2pnrqZHgNVuBuw/q9pDd1+wzSyttkzSMgMqh7cPOcH/NMzwhGt7zqfBJLzqH2FLZvj9tVlkLB2XjUQIzNMHozBLw4AaiZtUGM8C2ns9XzSIQyx9gf2nZwnWfCCJBhE0p4MMPXUaKsQLHVtZVPJEhhK/vbKTfxE+BfcghsuSHQ9aB8ktAY6VbAMZojPx3oc2CZvJAN1caKwrymu//fM6S+SG6NCpm24PJcxxm2KDQ/+C4oIh50YL2KW247yoXBaU42Dt6hcnxwV3CRkOPVjCH1lJrLz+4LAXY+niQHCJDg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

On May 27, 2025, at 10:20=E2=80=AFAM, Marcel Holtmann =
<marcel@holtmann.org> wrote:
>=20
>=20
> Hi Grant,
>=20
>> This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
>> input/output terminal abstraction.
>>=20
>> Substantive changes from the v7 version:
>>=20
>> * Fixed a typo in the  ASCII C0 and C1 control code mnemonics.
>>=20
>> Grant Erickson (9):
>> term: Initial revision.
>=20
> I actually reverted it back to my version and included printf / =
vprintf helpers.
>=20
> What is the purpose of l_term_set_bounds? Is it important for non-TTY =
setups since for TTY compatible terminals, this should not be needed.

It=E2=80=99s been a year and a half since I first deploy this, so bear =
with me as I attempt to clear some dust and cobwebs from some of the =
details.

Regarding l_term_set_bounds, It was a function that I appeared to have =
used during early prototyping but never ended up leveraging in this =
implementation wrapper:

    status_t
    Terminal :: SetBounds(
        const uint16_t &inRows,
        const uint16_t &inColumns
    )
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlEXPECT_ACTION(mEllTerminal !=3D nullptr,
                        done,
                        lRetval =3D ERROR_NOT_INITIALIZED);
            lRetval =3D l_term_set_bounds(mEllTerminal.get(),
                                    inRows,
                                    inColumns);
         done:
        return (lRetval);
    }

I suspect it was just a symmetric peer to my GetBounds observation =
method:

    status_t
    Terminal :: GetBounds(
        uint16_t &outRows,
        uint16_t &outColumns
    ) const
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlEXPECT_ACTION(mEllTerminal !=3D nullptr,
                        done,
                        lRetval =3D ERROR_NOT_INITIALIZED);
            lRetval =3D l_term_get_rows(mEllTerminal.get(),
                                  &outRows);
        nlREQUIRE_SUCCESS(lRetval, done);
            lRetval =3D l_term_get_columns(mEllTerminal.get(),
                                     &outColumns);
        nlREQUIRE_SUCCESS(lRetval, done);
         done:
        return (lRetval);
    }

> The  l_term_io_callback and l_term_process is something I don=E2=80=99t =
really like since I rather keep that internal.

The implementation needs run loop adaptation. Absent those functions, =
what would you propose instead?

My initializer, deinitializer, and run loop adaptation:

    status_t
    Terminal :: Init(
        FILE *inInput,
        FILE *inOutput
    )
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlREQUIRE_ACTION(inInput  !=3D nullptr, done, lRetval =3D =
-EINVAL);
        nlREQUIRE_ACTION(inOutput !=3D nullptr, done, lRetval =3D =
-EINVAL);
            lRetval =3D Init(fileno(inInput),
                       fileno(inOutput));
         done:
        return (lRetval);
    }
        status_t
    Terminal :: Init(
        const os_descriptor_t &inInput,
        const os_descriptor_t &inOutput
    )
    {
        status_t  lRetval =3D STATUS_SUCCESS;
            lRetval =3D osDescriptorValidate(inInput);
        nlREQUIRE_SUCCESS(lRetval, done);
            lRetval =3D osDescriptorValidate(inOutput);
        nlREQUIRE_SUCCESS(lRetval, done);
            mEllTerminal.reset(l_term_new());
        nlREQUIRE_ACTION(mEllTerminal !=3D nullptr, done, lRetval =3D =
-ENOMEM);
            lRetval =3D l_term_set_io_handler(mEllTerminal.get(), =
IoCallback, this);
        nlREQUIRE_SUCCESS(lRetval, done);
            lRetval =3D l_term_set_key_handler(mEllTerminal.get(), =
KeyCallback, this);
        nlREQUIRE_SUCCESS(lRetval, done);
            lRetval =3D l_term_set_input(mEllTerminal.get(), inInput);
        nlREQUIRE_SUCCESS(lRetval, done);
            lRetval =3D l_term_set_output(mEllTerminal.get(), inOutput);
        nlREQUIRE_SUCCESS(lRetval, done);
         done:
        if (lRetval < STATUS_SUCCESS)
        {
            if (mEllTerminal !=3D nullptr)
            {
                l_term_set_key_handler(mEllTerminal.get(), nullptr, =
nullptr);
                    l_term_set_io_handler(mEllTerminal.get(), nullptr, =
nullptr);
                    mEllTerminal.reset();
            }
        }
            return (lRetval);
    }
        status_t
    Terminal :: Shutdown(void)
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlEXPECT(mEllTerminal !=3D nullptr, done);
            if (IsAcquired())
        {
            Release();
        }
            l_term_set_key_handler(mEllTerminal.get(), nullptr, =
nullptr);
            l_term_set_io_handler(mEllTerminal.get(), nullptr, nullptr);
            mEllTerminal.reset();
         done:
        return (lRetval);
    }
        // MARK: Introspection
        bool
    Terminal :: IsAcquired(void) const
    {
        bool lRetval =3D false;
            nlEXPECT(mEllTerminal !=3D nullptr, done);
            lRetval =3D l_term_is_acquired(mEllTerminal.get());
         done:
        return (lRetval);
    }

    void
    Terminal :: IoCallback(
        const os_descriptor_t &inDescriptor,
        const bool &inReadable,
        const bool &inWritable
    )
    {
        nlREQUIRE(osDescriptorIsValid(inDescriptor), done);
            if (inReadable)
        {
            mDescriptorEventMap[inDescriptor] |=3D POLLIN;
        }
        else
        {
            mDescriptorEventMap[inDescriptor] &=3D ~POLLIN;
        }
            if (inWritable)
        {
            mDescriptorEventMap[inDescriptor] |=3D POLLOUT;
        }
        else
        {
            mDescriptorEventMap[inDescriptor] &=3D ~POLLOUT;
        }
         done:
        return;
    }
        status_t
    Terminal :: GetDescriptors(
        os_descriptor_t &inOutHighestDescriptor,
        fd_set &inOutReadDescriptors,
        fd_set &inOutWriteDescriptors,
        fd_set &inOutExceptionDescriptors
    ) const
    {
        DescriptorEventMap::const_iterator  lDescriptorEventMapCurrent =3D=

            mDescriptorEventMap.cbegin();
        DescriptorEventMap::const_iterator  lDescriptorEventMapLast    =3D=

            mDescriptorEventMap.cend();
        status_t                            lRetval                    =3D=

            STATUS_SUCCESS;
            while (lDescriptorEventMapCurrent !=3D
               lDescriptorEventMapLast)
        {
            // Simply handle the input descriptor. We assume that the
            // output descriptor is always ready for writing.
                if ((lDescriptorEventMapCurrent->second & POLLIN) &&
                osDescriptorIsValid(lDescriptorEventMapCurrent->first))
            {
                FD_SET(lDescriptorEventMapCurrent->first, =
&inOutReadDescriptors);
                    inOutHighestDescriptor =3D =
max(inOutHighestDescriptor, lDescriptorEventMapCurrent->first);
            }
                advance(lDescriptorEventMapCurrent, 1);
        }
            return (lRetval);
    }
        status_t
    Terminal :: HandleDescriptors(
        fd_set &inOutReadDescriptors,
        fd_set &inOutWriteDescriptors,
        fd_set &inOutExceptionDescriptors
    )
    {
        DescriptorEventMap::iterator  lDescriptorEventMapCurrent =3D
            mDescriptorEventMap.begin();
        DescriptorEventMap::iterator  lDescriptorEventMapLast    =3D
            mDescriptorEventMap.end();
        status_t                      lRetval                    =3D
            STATUS_SUCCESS;
            while (lDescriptorEventMapCurrent !=3D
               lDescriptorEventMapLast)
        {
            if (FD_ISSET(lDescriptorEventMapCurrent->first, =
&inOutReadDescriptors))
            {
                l_term_process(mEllTerminal.get());
            }
                advance(lDescriptorEventMapCurrent, 1);
        }
            return (lRetval);
    }

There=E2=80=99s a similar set of methods to adapt it to poll rather than =
select; however, I=E2=80=99ve elided those since you can more or less =
guess how they are implemented.

>> ell: Add include directive for 'ell/term.h'.
>> ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
>> term: Added 'l_term_*' symbols.
>=20
> These 3 were already in my latest set.

Acknowledged; I started with your patch set as a baseline so that =
reviewers could see the entire context given that your patches were not =
yet in-tree.

>=20
>> ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not
>>   running.
>=20
> Why is that important. It seems like a hack. If you haven=E2=80=99t =
successfully acquired the terminal, there is no point in writing to it =
since you have no idea what termios setting are dealing with.

Per the above, regrettably, at this point I don=E2=80=99t recall the =
issue that I had run into. For what they are worth, my output methods =
are:

    status_t
    Terminal :: Write(
        const char &inCharacter
    )
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlEXPECT_ACTION(mEllTerminal !=3D nullptr,
                        done,
                        lRetval =3D ERROR_NOT_INITIALIZED);
            lRetval =3D l_term_putchar(mEllTerminal.get(),
                                 inCharacter);
         done:
        return (lRetval);
    }
        status_t
    Terminal :: Write(
        const char *inString
    )
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlEXPECT_ACTION(mEllTerminal !=3D nullptr,
                        done,
                        lRetval =3D ERROR_NOT_INITIALIZED);
            lRetval =3D l_term_putstr(mEllTerminal.get(),
                                inString);
         done:
        return (lRetval);
    }
        status_t
    Terminal :: Write(
        const char *inString,
        const size_t &inStringLength
    )
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlEXPECT_ACTION(mEllTerminal !=3D nullptr,
                        done,
                        lRetval =3D ERROR_NOT_INITIALIZED);
            lRetval =3D l_term_putnstr(mEllTerminal.get(),
                                 inString,
                                 inStringLength);
         done:
        return (lRetval);
        }
        status_t
    Terminal :: WriteWithFormat(
        const char *inFormat,
        ...
    )
    {
        va_list  lArguments;
        status_t lRetval =3D STATUS_SUCCESS;
            va_start(lArguments, inFormat);
            lRetval =3D WriteWithFormat(inFormat, lArguments);
            va_end(lArguments);
            return (lRetval);
    }
        status_t
    Terminal :: WriteWithFormat(
        const char *inFormat,
        va_list inArguments
    )
    {
        status_t lRetval =3D STATUS_SUCCESS;
            nlEXPECT_ACTION(mEllTerminal !=3D nullptr,
                        done,
                        lRetval =3D ERROR_NOT_INITIALIZED);
            lRetval =3D l_term_vprint(mEllTerminal.get(),
                                inFormat,
                                inArguments);
         done:
        return (lRetval);
        }

>> ell/term: Return error on writes if the output descriptor is invalid.
>=20
> Seems like a fix for the previous change.

It might well be. Again, per the comment above about getting back into =
the context of a year and a half ago, it seems like there was a desire =
to be able to initialize an instance with the stdin / stdout file stream =
pointers and have things work as-is and then bootstrap into / out of =
those with the terminal as my line oriented UI/UX acquired / released =
the terminal as UI/UX elements were pushed/popped off the stack.

>> ell/edit: Rename 'l_term_{open,close}'.
>=20
> I incorporated that into my set. Makes sense to me.

Re-reviewing this particular patch and recollecting the acquire/release =
push/pop semantics around the UI/UX stack and stdin/stdout, I believe =
that starts to get at the -EPERM / -EBADF changes. Otherwise, I think =
the UI/UX stack would have effectively had to toggle in / toggle out a =
=E2=80=9CNULL Terminal=E2=80=9D as the actual terminal was acquired / =
released.

>> ell/term: Add an 'l_term_is_acquired' introspection function.
>=20
> I added it, but don=E2=80=99t really know how it would be used.

See above use case in the =E2=80=98Shutdown=E2=80=99 deinitializer.

>> ell/term: Added ASCII C0 and C1 control code mnemonics.
>=20
> Hmm. We could do that, but the constant name is too long for my taste. =
And why use an enum instead of defines?

enumerations seemed to be the prevailing style in ELL.

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
https://www.nuovations.com/

