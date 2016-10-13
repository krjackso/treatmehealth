package controllers

import (
	"github.com/pressly/chi"

	"github.com/krjackso/treatmehealth/api/models"
)

func Bootstrap(userModel models.UserModel) *chi.Mux {
	router := chi.NewRouter()

	authCtl := &AuthControllerImpl{userModel: userModel}

	router.Get("/api/auth/me", authCtl.Me)
	router.Head("/api/auth", authCtl.Index)

	userCtl := &UserControllerImpl{userModel: userModel}
	router.Get("/api/users/:id", userCtl.Get)
	router.Put("/api/users", userCtl.Put)

	return router
}
