Received: from mail-lf1-f52.google.com (mail-lf1-f52.google.com [209.85.167.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B64FBBA45
	for <ell@lists.linux.dev>; Wed,  4 Jan 2023 21:08:51 +0000 (UTC)
Received: by mail-lf1-f52.google.com with SMTP id g13so52247624lfv.7
        for <ell@lists.linux.dev>; Wed, 04 Jan 2023 13:08:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=8LQe6atWD8RgK1niV+Hqo3sJPgK2b/fa7QYV/CabZ/I=;
        b=jH1VffI2NhP0x596VFHvCpKj7qJ7X+7CBQuUJuz6bv2zYmliBtDhagh1a9/iPrgT5i
         fsAZPKtSa5CkGOTVPi1BV1UfWBL4Z+nrrJ1WkNHbku2+4dB1hoTCGZ3xHOf0pN/ZcO8L
         YcuvB/7D+TyputkIhJ6PxtDNVI83eB0HgbAeCQJXR1UiY4hbaFhnNHIZRqouxwpHoG9r
         RXa/nT9xHsZUQ8w/qoqUOyrO3bAkBLFSYdKaaA/XXUtlKc1brvOF8kFpc2tvBAOuPjjA
         o83Np7IllNLcufGcZgRe5tYjJ4gUdyNQ+9cIZQaCmf2zZyzYblYOpqGD+JAAlMyyPSoA
         k8hA==
X-Gm-Message-State: AFqh2kr1Z4TI50qcv/2mB9RqnCLFRIgTbfMj0OzCf9VqvQLexoHn6ibz
	qEvbaKOL4enYcqSalQydulvpiSPpzmQ6FV9l
X-Google-Smtp-Source: AMrXdXvn1laHlfp0LQhLrEdjTdR5BvSlRx+9rhLBRds8BiThsroP++RwU3Dwf1OXkxpS2R83uUZuMA==
X-Received: by 2002:a05:6512:e85:b0:4b5:aa59:28 with SMTP id bi5-20020a0565120e8500b004b5aa590028mr16309967lfb.38.1672866529103;
        Wed, 04 Jan 2023 13:08:49 -0800 (PST)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id y17-20020ac24e71000000b00492e3c8a986sm5250743lfs.264.2023.01.04.13.08.47
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 04 Jan 2023 13:08:48 -0800 (PST)
Received: by mail-lf1-f44.google.com with SMTP id bt23so35618522lfb.5
        for <ell@lists.linux.dev>; Wed, 04 Jan 2023 13:08:47 -0800 (PST)
X-Received: by 2002:a05:6512:340e:b0:4cb:27b9:e88 with SMTP id
 i14-20020a056512340e00b004cb27b90e88mr790725lfr.197.1672866527310; Wed, 04
 Jan 2023 13:08:47 -0800 (PST)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20230103220250.717876-3-marcel@holtmann.org>
In-Reply-To: <20230103220250.717876-3-marcel@holtmann.org>
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Date: Wed, 4 Jan 2023 22:08:34 +0100
X-Gmail-Original-Message-ID: <CAOq732KFvqDu94GGkUfBBszgR-yrCqUj2Lqx3=oPGdKDem0Zjw@mail.gmail.com>
Message-ID: <CAOq732KFvqDu94GGkUfBBszgR-yrCqUj2Lqx3=oPGdKDem0Zjw@mail.gmail.com>
Subject: Re: [PATCH 3/3] tls: Add support l_tls_set_alpn_list() and ALPN extension
To: Marcel Holtmann <marcel@holtmann.org>
Cc: ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Marcel,

On Tue, 3 Jan 2023 at 23:03, Marcel Holtmann <marcel@holtmann.org> wrote:
[...]
> +static bool tls_alpn_server_absent(struct l_tls *tls)
> +{
> +       if (!tls->alpn_list)
> +               return false;

I believe this returning false will break most usages of l_tls.

> +
> +       l_free(tls->selected_alpn);
> +       tls->selected_alpn = NULL;
> +
> +       TLS_DEBUG("ALPN not supported");
> +
> +       return true;
> +}
> +
>  /* Most extensions are not used when resuming a cached session */
>  #define SKIP_ON_RESUMPTION()   \
>         do {    \
> @@ -1025,6 +1089,15 @@ const struct tls_hello_extension tls_extensions[] = {
>                 tls_signature_algorithms_client_absent,
>                 NULL, NULL, NULL,
>         },
> +       {
> +               "ALPN", "application_layer_protocol_negotiation", 16,
> +               tls_alpn_client_write,
> +               NULL,
> +               NULL,
> +               NULL,
> +               tls_alpn_server_handle,
> +               tls_alpn_server_absent,
> +       },

If only the client side is implemented you might want to add a hint
either in the .h comment for l_tls_set_alpn_list(), or even in its
name.

>         {
>                 "Secure Renegotiation", "renegotiation_info", 0xff01,
>                 tls_renegotiation_info_client_write,
> diff --git a/ell/tls-private.h b/ell/tls-private.h
> index ac477885c5f7..dbc5457ef091 100644
> --- a/ell/tls-private.h
> +++ b/ell/tls-private.h
> @@ -218,6 +218,8 @@ struct l_tls {
>
>         struct tls_cipher_suite **cipher_suite_pref_list;
>         char *server_name;
> +       char **alpn_list;
> +       char *selected_alpn;
>
>         struct l_settings *session_settings;
>         char *session_prefix;
> diff --git a/ell/tls.c b/ell/tls.c
> index 9556efd932bc..8c1c9040ff89 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -3421,6 +3421,8 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
>                 l_free(tls->cipher_suite_pref_list);
>
>         l_free(tls->server_name);
> +       l_strv_free(tls->alpn_list);

Would perhaps l_tls_set_alpn_list(tls, NULL) be more future proof?

> +       l_free(tls->selected_alpn);
>         l_free(tls);
>  }
>
> @@ -3668,6 +3670,25 @@ LIB_EXPORT bool l_tls_set_server_name(struct l_tls *tls, const char *name)
>         return true;
>  }
>
> +LIB_EXPORT bool l_tls_set_alpn_list(struct l_tls *tls, const char **list)
> +{
> +       if (!tls)
> +               return false;
> +
> +       l_strv_free(tls->alpn_list);
> +       tls->alpn_list = l_strv_copy((char **) list);
> +
> +       return true;
> +}
> +
> +LIB_EXPORT const char *l_tls_get_alpn(struct l_tls *tls)
> +{
> +       if (!tls)
> +               return NULL;
> +
> +       return tls->selected_alpn;
> +}
> +
>  LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, struct l_queue *ca_certs)
>  {
>         if (tls->ca_certs) {
> diff --git a/ell/tls.h b/ell/tls.h
> index c931b5db0a54..e33f7c070008 100644
> --- a/ell/tls.h
> +++ b/ell/tls.h
> @@ -105,6 +105,9 @@ void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
>
>  bool l_tls_set_server_name(struct l_tls *tls, const char *name);
>
> +bool l_tls_set_alpn_list(struct l_tls *tls, const char **list);
> +const char *l_tls_get_alpn(struct l_tls *tls);

Since these and l_tls_set_server_name are extensions, I'd move them
further down in the file after the basic API, maybe aronud
l_tls_set_domain_mask.  Both patchsets look good otherwise.

Best regards
