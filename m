Content-Type: multipart/mixed; boundary="===============5099374182609926601=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: [PATCH] signal: pass signalfd_siginfo to notify callback
Date: Sun, 19 Sep 2021 15:00:24 +0000
Message-ID: <67176274-9e4e-6a4d-a0b5-22b2a8acf90d@maurer.systems>

--===============5099374182609926601==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Warning: breaks API/ABI of ell signal, but signalfd_siginfo contains a =

lot of useful information
---
  ell/main.c   | 4 ++--
  ell/signal.c | 6 +++---
  ell/signal.h | 3 ++-
  3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/ell/main.c b/ell/main.c
index 1a6cd60f..9697f019 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -604,7 +604,7 @@ struct signal_data {
  	void *user_data;
  };

-static void sigint_handler(void *user_data)
+static void sigint_handler(const struct signalfd_siginfo *si, void =

*user_data)
  {
  	struct signal_data *data =3D user_data;

@@ -612,7 +612,7 @@ static void sigint_handler(void *user_data)
  		data->callback(SIGINT, data->user_data);
  }

-static void sigterm_handler(void *user_data)
+static void sigterm_handler(const struct signalfd_siginfo *si, void =

*user_data)
  {
  	struct signal_data *data =3D user_data;

diff --git a/ell/signal.c b/ell/signal.c
index 2afdb45f..e756615b 100644
--- a/ell/signal.c
+++ b/ell/signal.c
@@ -66,7 +66,7 @@ static struct l_io *signalfd_io =3D NULL;
  static struct l_queue *signal_list =3D NULL;
  static sigset_t signal_mask;

-static void handle_callback(struct signal_desc *desc)
+static void handle_callback(struct signal_desc *desc, const struct =

signalfd_siginfo *si)
  {
  	const struct l_queue_entry *entry;

@@ -75,7 +75,7 @@ static void handle_callback(struct signal_desc *desc)
  		struct l_signal *signal =3D entry->data;

  		if (signal->callback)
-			signal->callback(signal->user_data);
+			signal->callback(si, signal->user_data);
  	}
  }

@@ -101,7 +101,7 @@ static bool signalfd_read_cb(struct l_io *io, void =

*user_data)
  	desc =3D l_queue_find(signal_list, desc_match_signo,
  						L_UINT_TO_PTR(si.ssi_signo));
  	if (desc)
-		handle_callback(desc);
+		handle_callback(desc, &si);

  	return true;
  }
diff --git a/ell/signal.h b/ell/signal.h
index 1d98476a..a6512d9b 100644
--- a/ell/signal.h
+++ b/ell/signal.h
@@ -30,8 +30,9 @@ extern "C" {
  #endif

  struct l_signal;
+struct signalfd_siginfo;

-typedef void (*l_signal_notify_cb_t) (void *user_data);
+typedef void (*l_signal_notify_cb_t) (const struct signalfd_siginfo =

*si, void *user_data);
  typedef void (*l_signal_destroy_cb_t) (void *user_data);

  struct l_signal *l_signal_create(uint32_t signo, l_signal_notify_cb_t =

callback,
--===============5099374182609926601==--

