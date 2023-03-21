<?php

namespace GlobalPayments\WooCommercePaymentGatewayProvider\Gateways;

use GlobalPayments\Api\Entities\Enums\Environment;
use GlobalPayments\Api\Entities\Enums\GatewayProvider;
use GlobalPayments\Api\Entities\Enums\TransactionStatus;
use GlobalPayments\WooCommercePaymentGatewayProvider\Plugin;
use GlobalPayments\WooCommercePaymentGatewayProvider\Gateways\Traits\MulticheckboxTrait;

defined( 'ABSPATH' ) || exit;

class GooglePayGateway extends AbstractGateway {

	use MulticheckboxTrait;

	/**
	 * Gateway ID
	 *
	 * @var string
	 */
	const GATEWAY_ID = 'globalpayments_googlepay';

	/**
	 * SDK gateway provider
	 *
	 * @var string
	 */
	public $gateway_provider = GatewayProvider::GP_API;

	/**
	 * @inheritdoc
	 */
	public $is_digital_wallet = true;

	/**
	 * Supported credit card types
	 *
	 * @var array
	 */
	public $cc_types;

	/**
	 * Global Payments Merchant Id
	 *
	 * @var string
	 *
	 */
	public $global_payments_merchant_id;

	/**
	 * Google Merchant Id
	 *
	 * @var int
	 */
	public $google_merchant_id;

	/**
	 * Google Merchant Name
	 *
	 * @var string
	 */
	public $google_merchant_name;

	/**
	 * Google pay button color
	 *
	 * @var string
	 */
	public $button_color;

	/**
	 * Payments action
	 *
	 * @var string
	 */
	public $payment_action;

	public function __construct() {
		parent::__construct();

		$this->gateway = new GpApiGateway( true );
	}

	public function get_first_line_support_email() {
		return 'api.integrations@globalpay.com';
	}

	public function configure_method_settings() {
		$this->id                 = self::GATEWAY_ID;
		$this->method_title       = __( 'GlobalPayments - Google Pay', 'googlepay-gateway-provider-for-woocommerce' );
		$this->method_description = __( 'Connect to the Google Pay gateway via Unified Payments Gateway', 'globalpayments-gateway-provider-for-woocommerce' );
	}

	public function get_frontend_gateway_options() {
		return array(
			'env'                         => $this->gateway->is_production ? Environment::PRODUCTION : Environment::TEST,
			'google_merchant_id'          => $this->google_merchant_id,
			'google_merchant_name'        => $this->google_merchant_name,
			'global_payments_merchant_id' => $this->global_payments_merchant_id,
			'cc_types'                    => $this->cc_types,
			'button_color'                => $this->button_color,
			'applepay_gateway_id'         => ApplePayGateway::GATEWAY_ID,
		);
	}

	public function get_backend_gateway_options() {
		return $this->gateway->get_backend_gateway_options();
	}


	protected function add_hooks() {
		parent::add_hooks();

		add_filter( 'pre_update_option_woocommerce_globalpayments_googlepay_settings', array(
			$this,
			'woocommerce_globalpayments_googlepay_settings'
		) );
	}

	public function woocommerce_globalpayments_googlepay_settings( $settings ) {
		if ( ! wc_string_to_bool( $settings['enabled'] ) ) {
			return $settings;
		}

		if ( empty( $settings['cc_types']  ) ) {
			add_action( 'admin_notices', function () {
				echo '<div id="message" class="notice notice-error is-dismissible"><p><strong>' .
				     __( 'Please provide at least one credit card types.', 'globalpayments-gateway-provider-for-woocommerce' ) . '</strong></p></div>';
			} );
		}

		return $settings;
	}

	public function get_gateway_form_fields() {
		return array(
			'global_payments_merchant_id' => array(
				'title'             => __( 'Global Payments Client ID*', 'globalpayments-gateway-provider-for-woocommerce' ),
				'type'              => 'text',
				'description'       => __( 'Your Client ID provided by Global Payments.', 'globalpayments-gateway-provider-for-woocommerce' ),
				'custom_attributes' => array( 'required' => 'required' ),
			),
			'google_merchant_id'          => array(
				'title'       => __( 'Google Merchant ID', 'globalpayments-gateway-provider-for-woocommerce' ),
				'type'        => 'text',
				'description' => __( 'Your Merchant ID provided by Google.', 'globalpayments-gateway-provider-for-woocommerce' ),
			),
			'google_merchant_name'          => array(
				'title'       => __( 'Google Merchant Display Name', 'globalpayments-gateway-provider-for-woocommerce' ),
				'type'        => 'text',
				'description' => __( 'Displayed to the customer in the Google Pay dialog.', 'globalpayments-gateway-provider-for-woocommerce' ),
			),
			'cc_types'                    => array(
				'title'   => __( 'Accepted Cards*', 'globalpayments-gateway-provider-for-woocommerce' ),
				'type'    => 'multiselectcheckbox',
				'class'   => 'accepted_cards required',
				'css'     => 'width: 450px; height: 110px',
				'options' => array(
					'VISA'       => 'Visa',
					'MASTERCARD' => 'MasterCard',
					'AMEX'       => 'AMEX',
					'DISCOVER'   => 'Discover',
					'JCB'        => 'JCB',
				),
				'default'	=> array( 'VISA' , 'MASTERCARD' , 'AMEX' , 'DISCOVER' , 'JCB' ),
			),
			'button_color'                => array(
				'title'   => __( 'Button Color', 'globalpayments-gateway-provider-for-woocommerce' ),
				'type'    => 'select',
				'default' => 'white',
				'options' => array(
					'white' => __( 'White', 'globalpayments-gateway-provider-for-woocommerce' ),
					'black' => __( 'Black', 'globalpayments-gateway-provider-for-woocommerce' ),
				),
			),
		);
	}

	public function init_form_fields() {
		$this->form_fields = array_merge(
			array(
				'enabled' => array(
					'title'   => __( 'Enable/Disable', 'globalpayments-gateway-provider-for-woocommerce' ),
					'type'    => 'checkbox',
					'label'   => __( 'Enable Gateway', 'globalpayments-gateway-provider-for-woocommerce' ),
					'default' => 'no',
				),
				'title'   => array(
					'title'             => __( 'Title', 'globalpayments-gateway-provider-for-woocommerce' ),
					'type'              => 'text',
					'description'       => __( 'This controls the title which the user sees during checkout.', 'globalpayments-gateway-provider-for-woocommerce' ),
					'default'           => __( 'Pay with Google Pay', 'globalpayments-gateway-provider-for-woocommerce' ),
					'desc_tip'          => true,
					'custom_attributes' => array( 'required' => 'required' ),
				),
			),
			$this->get_gateway_form_fields(),
			array(
				'payment_action' => array(
					'title'       => __( 'Payment Action', 'globalpayments-gateway-provider-for-woocommerce' ),
					'type'        => 'select',
					'description' => __( 'Choose whether you wish to capture funds immediately or authorize payment only for a delayed capture.', 'globalpayments-gateway-provider-for-woocommerce' ),
					'default'     => self::TXN_TYPE_SALE,
					'desc_tip'    => true,
					'options'     => array(
						self::TXN_TYPE_SALE      => __( 'Authorize + Capture', 'globalpayments-gateway-provider-for-woocommerce' ),
						self::TXN_TYPE_AUTHORIZE => __( 'Authorize only', 'globalpayments-gateway-provider-for-woocommerce' ),
					),
				),
			)
		);
	}

	public function tokenization_script() {
		wp_enqueue_script(
			'globalpayments-googlepay',
			( 'https://pay.google.com/gp/p/js/pay.js' ),
			array(),
			WC()->version,
			true
		);

		$this->helper_script();

		wp_enqueue_script(
			'globalpayments-wc-googlepay',
			Plugin::get_url( '/assets/frontend/js/globalpayments-googlepay.js' ),
			array( 'wc-checkout', 'globalpayments-googlepay', 'globalpayments-helper' ),
			WC()->version,
			true
		);

		wp_localize_script(
			'globalpayments-wc-googlepay',
			'globalpayments_googlepay_params',
			array(
				'id'              => $this->id,
				'gateway_options' => $this->get_frontend_gateway_options(),
			)
		);
	}

	public function payment_fields() {
		if ( is_checkout() ) {
			$this->tokenization_script();
			echo '<div>' . __( 'Pay with Google Pay', 'globalpayments-gateway-provider-for-woocommerce' ) . '</div>';
		}
	}

	public function mapResponseCodeToFriendlyMessage( $responseCode ) {
		if ( TransactionStatus::DECLINED === $responseCode ) {
			return __( 'Your payment was unsuccessful. Please try again or use a different payment method.', 'globalpayments-gateway-provider-for-woocommerce' );
		}

		return __( 'An error occurred while processing the card. Please try again or use a different payment method.', 'globalpayments-gateway-provider-for-woocommerce' );
	}
}
