package router

import (
	"net/http"

	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/util/authutil"
)

func Authenticated(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		bearer, ok := authutil.NewBearerAuthorization(r.Header)

		if !ok {
			http.Error(w, "", http.StatusUnauthorized)
			return
		}

		userId, valid := models.VerifyAccessToken(bearer)

		if !valid {
			http.Error(w, "", http.StatusUnauthorized)
			return
		}

		ctx := authutil.ContextWithUserId(r.Context(), userId)

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
