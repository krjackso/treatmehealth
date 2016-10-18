package routes

import (
	"github.com/pressly/chi"
	"github.com/pressly/chi/middleware"

	"github.com/krjackso/treatmehealth/api/controllers"
	"github.com/krjackso/treatmehealth/api/models"
)

func Bootstrap(userModel models.UserModel) *chi.Mux {
	router := chi.NewRouter()

	router.Use(middleware.RequestID)
	router.Use(middleware.RealIP)
	router.Use(middleware.Logger)
	router.Use(middleware.Recoverer)

	authCtl := &controllers.AuthControllerImpl{UserModel: userModel}

	router.Get("/api/auth/me", authCtl.Me)
	router.Head("/api/auth", authCtl.Index)
	router.Post("/api/auth/login", authCtl.Login)
	router.Post("/api/auth/refresh", authCtl.Refresh)

	userCtl := &controllers.UserControllerImpl{UserModel: userModel}
	router.Get("/api/users/:id", userCtl.Get)
	router.Put("/api/users", userCtl.Put)

	return router
}
