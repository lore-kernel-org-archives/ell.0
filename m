Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D491B14A08A
	for <ell@lists.linux.dev>; Sun, 31 Mar 2024 16:45:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711903562; cv=none; b=Ci+reJhjRwMtv3hYkIgcPLdGzqF2T6S3q/rDa3pBLQEdF/LZNeIsvNTVHm6BbxzZ9CWnQyN30DitZln+u0DYY115go/vmwXrh66B2PpJ59WtHk7VbRG+Plm1YRNNbEShv9xh15jffyLmg7FznbH3JIpmHsfJb9z1+YJHqonNfWU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711903562; c=relaxed/simple;
	bh=neQA9F4/pKogvFu1tWdGFMwWsOggbHg7de2+OVApDI8=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=EWu3B0MLU60jDAshOUgyqC7U+RQJIQdeXUsGPTkomxaX8rJhwYcSHsqIXnWQmi/Gy4KERAx4kgd2/I3BcEHS5Cywgp39z0wzlRPJx3dTS8pKGqbQdtskhusLXL2xiI85AD3R+EoVBMvd0HRq5JKvcnvaDsg/8Meg/RXEJMsVigw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=P/nqfNNH; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="P/nqfNNH"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id CF2AE1649B6;
	Sun, 31 Mar 2024 12:45:51 -0400 (EDT)
Received: from smtpclient.apple (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 77D55124F8E;
	Sun, 31 Mar 2024 12:45:51 -0400 (EDT)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.500.171.1.1\))
Subject: Re: [RFC v4] edit: Add basic support for input line editing
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <20231222221447.23737-1-marcel@holtmann.org>
Date: Sun, 31 Mar 2024 09:45:40 -0700
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <DFA20693-7B4F-447D-8CAB-9C01C617919C@nuovations.com>
References: <20231222221447.23737-1-marcel@holtmann.org>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3774.500.171.1.1)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=content-type:mime-version:subject:from:in-reply-to:date:cc:content-transfer-encoding:message-id:references:to; s=pair-202401062137; bh=kilKV7MicD0qMYa5Y2CMDgtHp0sUTnCH2dsBK3OqGXE=; b=P/nqfNNHF/oY7i0ywoZkUPwBNZOaQQiESrv84//Oa8NPE8yHN/ghURcgiFoB+Jo9AbRn4Gl+IJK4YKqm/XKg5ddrq08CD1SFVm+b4WWC5RDZTlxHTG7PTN15hr+wW3wQUZCEyZUva0LD9T9g3ZzC+9GSW0i+HOWQnXjso+4kbjuE6h7HFQ8755hK+zOS7AtZe3LZZicUE25qfkGAR30AdoAmuW6L6V0ZzmfHiYS/I+Sw8+MaZYdFIGxDDdqMN865UgHFDE/jnMx8Slx/bPWoZErCE08yMNHR3aL3k1bQppOJ5jBxRngt0XRicO6cXm2/EKkJcWBCT7ALE+wQCOhEgg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

On Dec 22, 2023, at 2:14=E2=80=AFPM, Marcel Holtmann =
<marcel@holtmann.org> wrote:
>=20
> This allows for simple line editing with history capabilities. On
> purpose this has no concept of terminal input or terminal output and
> just allows manipulation of an internal wide character string.
>=20
> The debug option is something that might need to be removed or at =
least
> changed a little bit, but right now it is nice to see the internal
> states.
>=20
> Following features are missing:
>=20
> 1) Work with words (delete, move etc.)
> 2) Tab completion
> 3) Hints system
>=20
> Following features are left to the user:
>=20
> 1) Showing the prompt
> 2) Switching to masked input
>=20
> The demo-edit is just for demonstration purposes and requires Curses =
to
> be available without any autoconf magic.
>=20
> With demo-cli there is a really simple command line handling example
> that uses an internal terminal abstraction.

Marcel:

Thank you again for pulling this together. This looks to be in strong =
shape for production use. This certainly bests libedit/editline for =
being non-blocking, readline for licensing friendliness, and linenoise =
for being far more customizable and flexible.

I=E2=80=99ve encountered a few areas that I think could improve use and =
integration along with a few unknowns that I=E2=80=99ve yet been able to =
track down, with or without analysis tools.

Happy to post a full diff against v4 if that=E2=80=99s helpful.

1. The fatal errors from demo-cli and demo-edit are probably best as =
warnings since not having a UTF-8 locale (my system has the C and POSIX =
locales but that=E2=80=99s it) does not seem fatal as long as the =
application is restricted to ASCII (and even then, it still may not be =
fatal):

    if (strcmp(nl_langinfo(CODESET), ENCODING_UTF8)) {
        fprintf(stderr, "WARNING: no %s codeset / character map; =
non-ASCII characters may not work\n", ENCODING_UTF8);
    }

2. Other than introspection functions, ideally all of the functions that =
can have would have an =E2=80=98int=E2=80=99 or =E2=80=98int32_t=E2=80=99 =
return signature and return =E2=80=980=E2=80=99 on success or =E2=80=98-<s=
ome POSIX error>=E2=80=99 on failure. With the Booleans, I find I have =
to synthesize an error any way for my application. It=E2=80=99d be =
easier to just to pass along whatever error l_edit or l_term =
encountered.

3. Ideally, all callbacks would take an instance pointer as their first =
argument, for example:

    typedef void (*l_edit_display_func_t) (struct l_edit *edit, const =
wchar_t *wstr, size_t wlen, size_t pos, void *user_data);

    typedef void (*l_term_key_func_t) (struct l_term *term, wint_t wch, =
void *user_data);

4. Ideally, the following would be public functions:

    int l_term_set_input(struct l_term *term, int fd);
    int l_term_set_output(struct l_term *term, int fd);

My application already has weak pointers to =E2=80=99stdin=E2=80=99 and =
=E2=80=99stdout=E2=80=99. I am able to use the above to just do:

    l_term_set_input(fileno(my_input_stream));
    l_term_set_output(fileno(my_output_stream));

5. Ideally, l_term would be more run loop adaptable. Toward that end, I =
would propose:

    typedef void (*l_term_io_func_t)(struct l_term *term,
                                     int fd,
                                     bool readable,
                                     bool writable,
                                     void *user_data);

    int l_term_set_io_handler(struct l_term *term,
                               l_term_io_func_t handler,
                               void *user_data);

with the following implementation added to / changed in term.c:

    #define IO_HANDLER(term, fd, readable, writable) \
        do {                                         \
            if (term && term->io_handler) {          \
                term->io_handler(term,               \
                                 fd,                 \
                                 readable,           \
                                 writable,           \
                                 term->io_data);     \
            }                                        \
        } while (0);

This is invoked with:

    IO_HANDLER(term, term->in_fd, 1, 0);
    IO_HANDLER(term, term->out_fd, 0, 1);

at the end of l_term_open and:

    IO_HANDLER(term, term->in_fd, 0, 0);
    IO_HANDLER(term, term->out_fd, 0, 0);

at the start of l_term_close. Both in lieu of the existing l_io calls.

It is also used in the newly-proposed l_term_set_input and =
l_term_set_output calls below.

    LIB_EXPORT int l_term_set_io_handler(struct l_term *term,
                    l_term_io_func_t handler, void *user_data)
    {
        if (!term)
            return -EINVAL;
   =20
        term->io_handler =3D handler;
        term->io_data =3D user_data;
   =20
        return 0;
    }
   =20
    LIB_EXPORT int l_term_set_input(struct l_term *term, int fd)
    {
        if (!term)
            return -EINVAL;
   =20
        if (fd < 0)
            return -EBADF;
   =20
        term->in_fd =3D fd;
        term->in_ops =3D NULL;
   =20
        IO_HANDLER(term, fd, 1, 0);
   =20
        return 0;
    }
   =20
    LIB_EXPORT int l_term_set_output(struct l_term *term, int fd)
    {
        if (!term)
            return -EINVAL;
   =20
        if (fd < 0)
            return -EBADF;
   =20
        term->out_fd =3D fd;
        term->out_ops =3D NULL;
   =20
        IO_HANDLER(term, fd, 0, 1);
   =20
        return 0;
    }
   =20
    LIB_EXPORT bool l_term_set_input_stdin(struct l_term *term)
    {
        return l_term_set_input(term, STDIN_FILENO) =3D=3D 0;
    }
   =20
    LIB_EXPORT bool l_term_set_output_stdout(struct l_term *term)
    {
        return l_term_set_output(term, STDOUT_FILENO) =3D=3D 0;
    }
   =20
Finally, I propose =E2=80=98l_term_process=E2=80=99 (or whatever it =
might be appropriate to name it as):

    LIB_EXPORT void l_term_process(struct l_term *term)
    {
        wchar_t wstr[2];
        ssize_t len;
        mbstate_t ps;
   =20
        if (!term)
            return;
   =20
        len =3D read(term->in_fd, term->key_buf + term->key_len,
                        sizeof(term->key_buf) - term->key_len);
        if (len < 0)
            return;
   =20
        term->key_len +=3D len;
   =20
        while (term->key_len > 0) {
            memset(&ps, 0, sizeof(ps));
   =20
            len =3D mbrtowc(wstr, term->key_buf, term->key_len, &ps);
            if (len < 0)
                break;
   =20
            memmove(term->key_buf, term->key_buf + len,
                            term->key_len - len);
            term->key_len -=3D len;
   =20
            if (term->key_handler) {
                wint_t wch =3D wstr[0];
                term->key_handler(term, wch, term->key_data);
            }
        }
    }
   =20
which is effectively the main body of =E2=80=98in_callback=E2=80=99 =
which could be preserved and made public as an adjunct helper function =
for applications that want =E2=80=9Call-in=E2=80=9D on ELL:

    LIB_EXPORT bool l_term_io_callback(struct l_io *io, void *user_data)
    {
        struct l_term *term =3D user_data;
       =20
        l_term_process(term);
   =20
        return true;
    }

The addition of =E2=80=98l_term_set_bounds=E2=80=99:

    int l_term_set_bounds(struct l_term *term, uint16_t rows, uint16_t =
columns);

would likewise allow the bounds changing and SIGWINCH handling to be =
outside of l_term with a public helper that could / can be leveraged for =
those that want =E2=80=9Call-in=E2=80=9D on ELL. I haven=E2=80=99t fully =
completed that refactoring yet.

6. I suspect integrators will end up copy-and-pasting the whole of =
handle_input from demo-cli frequently which is mostly an emacs-style key =
binding =E2=80=9Cdefault". That is certainly where I started with hooks =
added for handling LF (basically =E2=80=9Chandle input=E2=80=9D, the =
crux of the application) and Ctrl-C (which stops and quits my run loop). =
I=E2=80=99ve not yet forecast the right API, but it seems like there is =
a l_edit_emacs_handler or some such that can be set with a companion =
input_handler and control_handler or some such which pass along the =
input line and control sequence for application-specific handling.

7. l_edit_set_max_display_length unsurprisingly calls update_display =
which calls display_handler. Consequently, calling =
l_edit_set_max_display_length from display_handler creates an infinite =
loop. A warning comment probably serve future integrators well.

8. Finally, there seems to be a memory smasher somewhere. When I =
integrate l_edit and l_term, my application crashes during =
initialization with heap corruption sometime after I do initialization =
which amounts to:

    status_t ElementController :: InitEll(
        FILE *inInputStream,
        FILE *inOutputStream,
        FILE *inErrorStream
    )
    {
        struct l_term *  lEllTerm =3D nullptr;
        struct l_edit *  lEllEdit =3D nullptr;
        bool             lOpened  =3D false;
        bool             lStatus;
        status_t         lRetval  =3D STATUS_SUCCESS;
   =20
        nlREQUIRE_ACTION(inInputStream  !=3D nullptr, done, lRetval =3D =
-EINVAL);
        nlREQUIRE_ACTION(inOutputStream !=3D nullptr, done, lRetval =3D =
-EINVAL);
        nlREQUIRE_ACTION(inErrorStream  !=3D nullptr, done, lRetval =3D =
-EINVAL);
   =20
        mDescriptorEventMap.clear();
   =20
        lEllTerm =3D l_term_new();
        nlREQUIRE_ACTION(lEllTerm !=3D nullptr, done, lRetval =3D =
-ENOMEM);
   =20
        lEllEdit =3D l_edit_new();
        nlREQUIRE_ACTION(lEllEdit !=3D nullptr, done, lRetval =3D =
-ENOMEM);
   =20
        lStatus =3D l_term_set_io_handler(lEllTerm, DescriptorCallback, =
this);
        nlREQUIRE_ACTION(lStatus, done, lRetval =3D =
ERROR_INITIALIZATION_FAILED);
   =20
        lStatus =3D l_term_set_key_handler(lEllTerm, KeyCallback, this);
        nlREQUIRE_ACTION(lStatus, done, lRetval =3D =
ERROR_INITIALIZATION_FAILED);
   =20
        lRetval =3D l_term_set_input(lEllTerm, fileno(inInputStream));
        nlREQUIRE_SUCCESS(lRetval, done);
   =20
        lRetval =3D l_term_set_output(lEllTerm, fileno(inOutputStream));
        nlREQUIRE_SUCCESS(lRetval, done);
   =20
        lOpened =3D l_term_open(lEllTerm);
        nlREQUIRE_ACTION(lOpened, done, lRetval =3D =
ERROR_INITIALIZATION_FAILED);
   =20
        lStatus =3D l_term_get_max_columns(lEllTerm, &mTermColumnsMax);
        nlREQUIRE_ACTION(lStatus, done, lRetval =3D =
ERROR_INITIALIZATION_FAILED);
   =20
        lStatus =3D l_edit_set_max_display_length(lEllEdit, =
mTermColumnsMax);
        nlREQUIRE_ACTION(lStatus, done, lRetval =3D =
ERROR_INITIALIZATION_FAILED);
   =20
        lStatus =3D l_edit_set_display_handler(lEllEdit, =
DisplayCallback, this);
        nlREQUIRE_ACTION(lStatus, done, lRetval =3D =
ERROR_INITIALIZATION_FAILED);
   =20
        mEllTerm =3D lEllTerm;
        mEllEdit =3D lEllEdit;
   =20
     done:
        if (lRetval < STATUS_SUCCESS)
        {
            if (lEllEdit !=3D nullptr)
            {
                l_edit_free(lEllEdit);
            }
   =20
            if (lEllTerm !=3D nullptr)
            {
                if (lOpened)
                    l_term_close(lEllTerm);
   =20
                l_term_free(lEllTerm);
            }
        }
       =20
        return (lRetval);
    }

If I return to using libedit/editline, it=E2=80=99s fine. If I just =
completely remove l_edit/l_term, it=E2=80=99s fine. Unfortunately and =
surprisingly, neither clang scan-build nor asan are able to zero in =
fully on the issue. Though, when it crashes on Armv7, asan indicates a =
read on 0x0 and often a corrupted PC and stack pointer of 0x0. My =
suspicion is there is a null or garbage dereference happening somewhere.

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
https://www.nuovations.com/=
