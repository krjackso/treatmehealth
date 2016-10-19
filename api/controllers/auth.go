package controllers

import (
	"net/http"
	"time"

	"github.com/pressly/chi/render"

	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/util/authutil"
	"github.com/krjackso/treatmehealth/api/util/routes"
)

type AuthControllerImpl struct {
	UserModel models.UserModel
}

type AuthController interface {
	Index(http.ResponseWriter, http.Request)
	Login(http.ResponseWriter, http.Request)
	Refresh(http.ResponseWriter, http.Request)
}

type AuthResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token,omitempty"`
	ExpiresAt    int64  `json:"expires_at"`
	Href         string `json:"href"`
}

func (self *AuthControllerImpl) Index(w http.ResponseWriter, r *http.Request) {

}

func (self *AuthControllerImpl) Login(w http.ResponseWriter, r *http.Request) {
	auth := authutil.NewBasicAuthorization(r.Header)
	if auth == nil {
		http.Error(w, "Invalid Authorization Header", http.StatusBadRequest)
		return
	}

	ctx := r.Context()
	user, err := self.UserModel.GetByUsername(ctx, auth.Username)
	if err != nil {
		panic(err)
	}

	if user == nil {
		http.Error(w, "", http.StatusUnauthorized)
		return
	}

	if !user.Credential.Verify(auth.Password) {
		http.Error(w, "", http.StatusUnauthorized)
		return
	}

	refreshToken := models.NewRefreshToken()

	err = self.UserModel.AddRefreshToken(ctx, user.Id, refreshToken)
	if err != nil {
		println("Error adding refresh token: " + err.Error())
	}

	accessToken, expiresAt := models.NewAccessToken(user.Id)

	render.JSON(w, r, &AuthResponse{
		RefreshToken: refreshToken.Token,
		AccessToken:  accessToken,
		ExpiresAt:    expiresAt,
		Href:         routes.HyperGetUser(user.Id),
	})
}

func (self *AuthControllerImpl) Refresh(w http.ResponseWriter, r *http.Request) {
	auth := authutil.NewBasicAuthorization(r.Header)
	if auth == nil {
		http.Error(w, "Invalid Authorization header", http.StatusBadRequest)
		return
	}

	ctx := r.Context()
	user, err := self.UserModel.GetByUsername(ctx, auth.Username)
	if err != nil {
		panic(err)
	}

	if user == nil {
		http.Error(w, "", http.StatusUnauthorized)
		return
	}

	token, err := self.UserModel.GetRefreshToken(ctx, user.Id, auth.Password)
	if err != nil {
		panic(err)
	}

	if token == nil {
		http.Error(w, "", http.StatusUnauthorized)
		return
	}

	if token.ExpiresAt.Before(time.Now().UTC()) {
		http.Error(w, "", http.StatusUnauthorized)
		return
	}

	accessToken, expiresAt := models.NewAccessToken(user.Id)

	render.JSON(w, r, &AuthResponse{
		AccessToken: accessToken,
		ExpiresAt:   expiresAt,
		Href:        routes.HyperGetUser(user.Id),
	})
}
