package services

import (
	"cloud.google.com/go/datastore"
	"context"
	"fmt"
)

type Datastore struct {
	project   string
	namespace string
	Client    *datastore.Client
}

func NewDatastore(project, namespace string) *Datastore {
	ctx := datastore.WithNamespace(context.Background(), namespace)
	client, err := datastore.NewClient(ctx, project)

	if err != nil {
		panic(fmt.Errorf("Failed to initialize datastore client: %v", err))
	}

	return &Datastore{project: project, namespace: namespace, Client: client}
}

func (self *Datastore) NewContext(ctx context.Context) context.Context {
	return datastore.WithNamespace(ctx, self.namespace)
}
