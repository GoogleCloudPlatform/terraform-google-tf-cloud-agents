package oidc_simple

import (
	"fmt"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestOidcSimple(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t, tft.WithRetryableTerraformErrors(tft.CommonRetryableErrors, 2, 3*time.Second))

	bpt.DefineVerify(func(assert *assert.Assertions) {
		bpt.DefaultVerify(assert)
		
		projectId := bpt.GetStringOutput("project_id")
		poolName := bpt.GetStringOutput("pool_name")
		providerName := bpt.GetStringOutput("provider_name")
		saEmail := bpt.GetStringOutput("sa_email")

		gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectId, "--format=json"})
		op := gcloud.Run(t, fmt.Sprintf("iam workload-identity-pools describe %s --location=global", poolName), gcloudArgs)

		assert.Equal(op.Get("name").String(), poolName, "Workload Identity Poo should have the right name")
		assert.Equal(op.Get("description").String(), "Workload Identity Pool managed by Terraform", "Description should match to show WIP managed by Terraform")
		assert.Equal(op.Get("state").String(), "ACTIVE", "Workload Identity Pool status should be ACTIVE")

		op = gcloud.Run(t, fmt.Sprintf("iam workload-identity-pools providers describe %s --workload-identity-pool=%s --location=global",providerName, poolName), gcloudArgs)
		assert.Equal(op.Get("name").String(), providerName, "Workload Identity Poo should have the right name")
		assert.Equal(op.Get("oidc.issuerUri").String(), "https://app.terraform.io", "OIDC issuer should match with Terraform Cloud's endpoint")
		assert.Equal(op.Get("state").String(), "ACTIVE", "Workload Identity Pool status should be ACTIVE")
		
		op = gcloud.Run(t, fmt.Sprintf("iam service-accounts get-iam-policy %s",saEmail), gcloudArgs)
		assert.Equal(op.Get("bindings.0.role").String(), "roles/iam.workloadIdentityUser", "Service Account should have workloadIdentityUser role")
	})

	bpt.Test()
}
