package tfc_agent_gke_simple

import (
	"fmt"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestTfcAgentGkeSimple(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t, tft.WithRetryableTerraformErrors(tft.CommonRetryableErrors, 2, 3*time.Second))

	bpt.DefineVerify(func(assert *assert.Assertions) {
		bpt.DefaultVerify(assert)
		
		projectId := bpt.GetStringOutput("project_id")
		clusterName := bpt.GetStringOutput("cluster_name")
		clusterCaCertificate := bpt.GetStringOutput("ca_certificate")
		location := bpt.GetStringOutput("location")
		serviceAccount := bpt.GetStringOutput("service_account")

		gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectId, "--region", location, "--format=json"})
		op := gcloud.Run(t, fmt.Sprintf("container clusters describe %s", clusterName), gcloudArgs)

		assert.Equal(op.Get("status").String(),"RUNNING", "GKE cluster should be up and running")
		assert.Equal(op.Get("masterAuth.clusterCaCertificate").String(), clusterCaCertificate, "GKE cluster should be up and running")
		assert.Equal(op.Get("nodeConfig.serviceAccount").String(), serviceAccount, "GKE cluster should have the right Service Account attached")
		assert.Equal(op.Get("nodePools.0.status").String(),"RUNNING", "Node pools should have RUNNING status")
		assert.Equal(op.Get("nodePools.0.config.metadata.cluster_name").String(), clusterName, "Node pools should be attached to the right cluster")
		assert.Equal(op.Get("nodePools.0.config.serviceAccount").String(), serviceAccount, "Node pools should be attached to the right Service Account attached")
	})

	bpt.Test()
}
